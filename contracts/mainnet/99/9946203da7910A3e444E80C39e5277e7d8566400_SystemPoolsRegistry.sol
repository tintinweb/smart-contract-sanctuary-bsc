// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";
import "@dlsl/dev-modules/libs/arrays/Paginator.sol";

import "./interfaces/IRegistry.sol";
import "./interfaces/ISystemParameters.sol";
import "./interfaces/IAssetParameters.sol";
import "./interfaces/IDefiCore.sol";
import "./interfaces/IRewardsDistribution.sol";
import "./interfaces/ISystemPoolsRegistry.sol";
import "./interfaces/IBasicPool.sol";
import "./interfaces/IPriceManager.sol";
import "./interfaces/ISystemPoolsFactory.sol";

contract SystemPoolsRegistry is ISystemPoolsRegistry, Initializable, AbstractDependant {
    using Paginator for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using Math for uint256;

    address internal systemOwnerAddr;
    IRegistry internal registry;
    ISystemParameters internal systemParameters;
    IAssetParameters internal assetParameters;
    IDefiCore internal defiCore;
    IRewardsDistribution internal rewardsDistribution;
    ISystemPoolsFactory internal systemPoolsFactory;
    IPriceManager internal priceManager;

    bytes32 public override nativeAssetKey;
    bytes32 public override rewardsAssetKey;
    EnumerableSet.Bytes32Set internal allSupportedAssetKeys;

    mapping(PoolType => PoolTypeInfo) internal poolTypesInfo;
    mapping(bytes32 => PoolInfo) public override poolsInfo;
    mapping(address => bool) public override existingLiquidityPools;

    modifier onlySystemOwner() {
        require(
            msg.sender == systemOwnerAddr,
            "SystemPoolsRegistry: Only system owner can call this function."
        );
        _;
    }

    function systemPoolsRegistryInitialize(
        address _liquidityPoolImpl,
        bytes32 _nativeAssetKey,
        bytes32 _rewardsAssetKey
    ) external initializer {
        poolTypesInfo[PoolType.LIQUIDITY_POOL].poolBeaconAddr = address(
            new UpgradeableBeacon(_liquidityPoolImpl)
        );

        nativeAssetKey = _nativeAssetKey;
        rewardsAssetKey = _rewardsAssetKey;
    }

    function setDependencies(address _contractsRegistry) external override dependant {
        IRegistry _registry = IRegistry(_contractsRegistry);

        registry = _registry;
        systemOwnerAddr = _registry.getSystemOwner();
        systemParameters = ISystemParameters(_registry.getSystemParametersContract());
        assetParameters = IAssetParameters(_registry.getAssetParametersContract());
        defiCore = IDefiCore(_registry.getDefiCoreContract());
        priceManager = IPriceManager(_registry.getPriceManagerContract());
        rewardsDistribution = IRewardsDistribution(_registry.getRewardsDistributionContract());
        systemPoolsFactory = ISystemPoolsFactory(_registry.getSystemPoolsFactoryContract());
    }

    function updateRewardsAssetKey(bytes32 _newRewardsAssetKey) external onlySystemOwner {
        require(
            IBasicPool(poolsInfo[_newRewardsAssetKey].poolAddr).assetAddr() ==
                systemParameters.getRewardsTokenAddress(),
            "SystemPoolsRegistry: Incorrect new rewards asset key."
        );

        rewardsAssetKey = _newRewardsAssetKey;
    }

    function addPoolsBeacon(PoolType _poolType, address _poolImpl)
        external
        override
        onlySystemOwner
    {
        PoolTypeInfo storage _poolTypeInfo = poolTypesInfo[_poolType];

        require(
            _poolTypeInfo.poolBeaconAddr == address(0),
            "SystemPoolsRegistry: Pools beacon for passed pool type already set."
        );

        _poolTypeInfo.poolBeaconAddr = address(new UpgradeableBeacon(_poolImpl));
    }

    function addLiquidityPool(
        address _assetAddr,
        bytes32 _assetKey,
        address _chainlinkOracle,
        string calldata _tokenSymbol,
        bool _isCollateral
    ) external override onlySystemOwner {
        _addPool(
            _assetAddr,
            _assetKey,
            _chainlinkOracle,
            _tokenSymbol,
            _isCollateral,
            PoolType.LIQUIDITY_POOL
        );
    }

    function addStablePool(
        address _assetAddr,
        bytes32 _assetKey,
        address _chainlinkOracle
    ) external override onlySystemOwner {
        require(
            systemParameters.getStablePoolsAvailability(),
            "SystemPoolsRegistry: Stable pools are unavailable."
        );

        _addPool(_assetAddr, _assetKey, _chainlinkOracle, "", true, PoolType.STABLE_POOL);
    }

    function upgradePoolsImpl(PoolType _poolType, address _newPoolsImpl)
        external
        override
        onlySystemOwner
    {
        address _poolBeacon = poolTypesInfo[_poolType].poolBeaconAddr;

        require(_poolBeacon != address(0), "SystemPoolsRegistry: Unsupported pool type.");

        UpgradeableBeacon(_poolBeacon).upgradeTo(_newPoolsImpl);
    }

    function injectDependenciesToExistingPools() external override onlySystemOwner {
        IRegistry _registry = registry;

        address[] memory _allPools = getAllPools();

        for (uint256 i = 0; i < _allPools.length; i++) {
            AbstractDependant(_allPools[i]).setDependencies(address(_registry));
        }
    }

    function injectDependencies(uint256 _offset, uint256 _limit)
        external
        override
        onlySystemOwner
    {
        IRegistry _registry = registry;

        address[] memory _pools = getPools(_offset, _limit);

        for (uint256 i = 0; i < _pools.length; i++) {
            AbstractDependant(_pools[i]).setDependencies(address(_registry));
        }
    }

    function getLiquidityPoolsInfo(bytes32[] calldata _assetKeys)
        external
        view
        override
        returns (LiquidityPoolInfo[] memory _poolsInfo)
    {
        IAssetParameters _assetParametrs = assetParameters;

        _poolsInfo = new LiquidityPoolInfo[](_assetKeys.length);

        for (uint256 i = 0; i < _assetKeys.length; i++) {
            _poolsInfo[i] = _getLiquidityPoolInfo(
                _assetKeys[i],
                ILiquidityPool(poolsInfo[_assetKeys[i]].poolAddr),
                _assetParametrs
            );
        }
    }

    function getStablePoolsInfo(bytes32[] calldata _assetKeys)
        external
        view
        override
        returns (StablePoolInfo[] memory _poolsInfo)
    {
        _poolsInfo = new StablePoolInfo[](_assetKeys.length);

        for (uint256 i = 0; i < _assetKeys.length; i++) {
            _poolsInfo[i] = StablePoolInfo(
                _getBasePoolInfo(_assetKeys[i], IBasicPool(poolsInfo[_assetKeys[i]].poolAddr))
            );
        }
    }

    function getDetailedLiquidityPoolInfo(bytes32 _assetKey)
        external
        view
        override
        returns (DetailedLiquidityPoolInfo memory)
    {
        ILiquidityPool _liquidityPool = ILiquidityPool(poolsInfo[_assetKey].poolAddr);
        IAssetParameters _parameters = assetParameters;

        IAssetParameters.MainPoolParams memory _mainPoolParams = _parameters.getMainPoolParams(
            _assetKey
        );

        uint256 _availableToBorrow = _liquidityPool.getAvailableToBorrowLiquidity();
        uint256 _totalReserves = _liquidityPool.totalReserves();
        (uint256 _distrSupplyAPY, uint256 _distrBorrowAPY) = rewardsDistribution.getAPY(_assetKey);

        return
            DetailedLiquidityPoolInfo(
                _getLiquidityPoolInfo(_assetKey, _liquidityPool, _parameters),
                _mainPoolParams,
                _availableToBorrow,
                _liquidityPool.getAmountInUSD(_availableToBorrow),
                _totalReserves,
                _liquidityPool.getAmountInUSD(_totalReserves),
                _distrSupplyAPY,
                _distrBorrowAPY
            );
    }

    function getDonationInfo() external view override returns (DonationInfo memory) {
        bytes32[] memory _allKeys = getAllSupportedAssetKeys();

        uint256 _availableToDonateInUSD;

        for (uint256 i = 0; i < _allKeys.length; i++) {
            IBasicPool _basicPool = IBasicPool(poolsInfo[_allKeys[i]].poolAddr);

            _availableToDonateInUSD += _basicPool.getAmountInUSD(_basicPool.totalReserves());
        }

        return
            DonationInfo(
                defiCore.totalDonationInUSD(),
                _availableToDonateInUSD,
                systemParameters.getDonationAddress()
            );
    }

    function getRewardsLiquidityPool() external view override returns (address) {
        return poolsInfo[rewardsAssetKey].poolAddr;
    }

    function getPoolsBeacon(PoolType _poolType) external view override returns (address) {
        return poolTypesInfo[_poolType].poolBeaconAddr;
    }

    function getPoolsImpl(PoolType _poolType) external view override returns (address) {
        return UpgradeableBeacon(poolTypesInfo[_poolType].poolBeaconAddr).implementation();
    }

    function onlyExistingPool(bytes32 _assetKey) public view override returns (bool) {
        return poolsInfo[_assetKey].poolAddr != address(0);
    }

    function getAllSupportedAssetKeysCount()
        public
        view
        override
        returns (uint256 _allAsetsCount)
    {
        return allSupportedAssetKeys.length();
    }

    function getSupportedAssetKeysCountByType(PoolType _poolType)
        public
        view
        override
        returns (uint256)
    {
        return poolTypesInfo[_poolType].supportedAssetKeys.length();
    }

    function getAllSupportedAssetKeys() public view override returns (bytes32[] memory) {
        return allSupportedAssetKeys.part(0, getAllSupportedAssetKeysCount());
    }

    function getAllSupportedAssetKeysByType(PoolType _poolType)
        public
        view
        override
        returns (bytes32[] memory)
    {
        return
            getSupportedAssetKeysByType(_poolType, 0, getSupportedAssetKeysCountByType(_poolType));
    }

    function getSupportedAssetKeys(uint256 _offset, uint256 _limit)
        public
        view
        override
        returns (bytes32[] memory)
    {
        return allSupportedAssetKeys.part(_offset, _limit);
    }

    function getSupportedAssetKeysByType(
        PoolType _poolType,
        uint256 _offset,
        uint256 _limit
    ) public view override returns (bytes32[] memory) {
        return poolTypesInfo[_poolType].supportedAssetKeys.part(_offset, _limit);
    }

    function getAllPools() public view override returns (address[] memory) {
        return _getPoolsAddresses(getAllSupportedAssetKeys());
    }

    function getAllPoolsByType(PoolType _poolType)
        external
        view
        override
        returns (address[] memory)
    {
        return _getPoolsAddresses(getAllSupportedAssetKeysByType(_poolType));
    }

    function getPools(uint256 _offset, uint256 _limit)
        public
        view
        override
        returns (address[] memory)
    {
        return _getPoolsAddresses(getSupportedAssetKeys(_offset, _limit));
    }

    function getPoolsByType(
        PoolType _poolType,
        uint256 _offset,
        uint256 _limit
    ) external view override returns (address[] memory) {
        return _getPoolsAddresses(getSupportedAssetKeysByType(_poolType, _offset, _limit));
    }

    function _addPool(
        address _assetAddr,
        bytes32 _assetKey,
        address _chainlinkOracle,
        string memory _tokenSymbol,
        bool _isCollateral,
        PoolType _poolType
    ) internal {
        require(_assetKey > 0, "SystemPoolsRegistry: Unable to add an asset without a key.");
        require(
            _assetAddr != address(0),
            "SystemPoolsRegistry: Unable to add an asset with a zero address."
        );
        require(
            !onlyExistingPool(_assetKey),
            "SystemPoolsRegistry: Liquidity pool with such a key already exists."
        );

        address _poolAddr;

        if (_poolType == PoolType.LIQUIDITY_POOL) {
            _poolAddr = systemPoolsFactory.newLiquidityPool(_assetAddr, _assetKey, _tokenSymbol);
        } else {
            _poolAddr = systemPoolsFactory.newStablePool(_assetAddr, _assetKey);
        }

        assetParameters.setPoolInitParams(_assetKey, _isCollateral);

        allSupportedAssetKeys.add(_assetKey);
        poolTypesInfo[_poolType].supportedAssetKeys.add(_assetKey);

        poolsInfo[_assetKey] = PoolInfo(_poolAddr, _poolType);
        existingLiquidityPools[_poolAddr] = true;

        priceManager.addOracle(_assetKey, _assetAddr, _chainlinkOracle);

        emit PoolAdded(_assetKey, _assetAddr, _poolAddr, _poolType);
    }

    function _getLiquidityPoolInfo(
        bytes32 _assetKey,
        ILiquidityPool _liquidityPool,
        IAssetParameters _parameters
    ) internal view returns (LiquidityPoolInfo memory) {
        uint256 _marketSize = _liquidityPool.getTotalLiquidity();
        (uint256 _distrSupplyAPY, ) = rewardsDistribution.getAPY(_assetKey);

        return
            LiquidityPoolInfo(
                _getBasePoolInfo(_assetKey, _liquidityPool),
                _liquidityPool.getAPY(),
                _distrSupplyAPY,
                _marketSize,
                _liquidityPool.getAmountInUSD(_marketSize),
                _liquidityPool.getBorrowPercentage(),
                _parameters.isAvailableAsCollateral(_assetKey)
            );
    }

    function _getBasePoolInfo(bytes32 _assetKey, IBasicPool _basicPool)
        internal
        view
        returns (BasePoolInfo memory)
    {
        uint256 _totalBorrowed = _basicPool.getTotalBorrowedAmount();
        (, uint256 _distrBorrowAPY) = rewardsDistribution.getAPY(_assetKey);

        return
            BasePoolInfo(
                _assetKey,
                _basicPool.assetAddr(),
                _basicPool.getAnnualBorrowRate(),
                _distrBorrowAPY,
                _totalBorrowed,
                _basicPool.getAmountInUSD(_totalBorrowed)
            );
    }

    function _getPoolsAddresses(bytes32[] memory _assetKeys)
        internal
        view
        returns (address[] memory _poolsArr)
    {
        _poolsArr = new address[](_assetKeys.length);

        for (uint256 i = 0; i < _assetKeys.length; i++) {
            _poolsArr[i] = poolsInfo[_assetKeys[i]].poolAddr;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

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
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
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
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
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
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

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
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
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
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
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
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

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
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/UpgradeableBeacon.sol)

pragma solidity ^0.8.0;

import "./IBeacon.sol";
import "../../access/Ownable.sol";
import "../../utils/Address.sol";

/**
 * @dev This contract is used in conjunction with one or more instances of {BeaconProxy} to determine their
 * implementation contract, which is where they will delegate all function calls.
 *
 * An owner is able to change the implementation the beacon points to, thus upgrading the proxies that use this beacon.
 */
contract UpgradeableBeacon is IBeacon, Ownable {
    address private _implementation;

    /**
     * @dev Emitted when the implementation returned by the beacon is changed.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Sets the address of the initial implementation, and the deployer account as the owner who can upgrade the
     * beacon.
     */
    constructor(address implementation_) {
        _setImplementation(implementation_);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function implementation() public view virtual override returns (address) {
        return _implementation;
    }

    /**
     * @dev Upgrades the beacon to a new implementation.
     *
     * Emits an {Upgraded} event.
     *
     * Requirements:
     *
     * - msg.sender must be the owner of the contract.
     * - `newImplementation` must be a contract.
     */
    function upgradeTo(address newImplementation) public virtual onlyOwner {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Sets the implementation contract address for this beacon
     *
     * Requirements:
     *
     * - `newImplementation` must be a contract.
     */
    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
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

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../data-structures/StringSet.sol";

/**
 *  @notice Library for pagination.
 *
 *  Supports the following data types `uin256[]`, `address[]`, `bytes32[]`, `UintSet`,
 * `AddressSet`, `BytesSet`, `StringSet`.
 *
 */
library Paginator {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using StringSet for StringSet.Set;

    /**
     * @notice Returns part of an array.
     * @dev All functions below have the same description.
     *
     * Examples:
     * - part([4, 5, 6, 7], 0, 4) will return [4, 5, 6, 7]
     * - part([4, 5, 6, 7], 2, 4) will return [6, 7]
     * - part([4, 5, 6, 7], 2, 1) will return [6]
     *
     * @param arr Storage array.
     * @param offset Offset, index in an array.
     * @param limit Number of elements after the `offset`.
     */
    function part(
        uint256[] storage arr,
        uint256 offset,
        uint256 limit
    ) internal view returns (uint256[] memory list) {
        uint256 to = _handleIncomingParametersForPart(arr.length, offset, limit);

        list = new uint256[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            list[i - offset] = arr[i];
        }
    }

    function part(
        address[] storage arr,
        uint256 offset,
        uint256 limit
    ) internal view returns (address[] memory list) {
        uint256 to = _handleIncomingParametersForPart(arr.length, offset, limit);

        list = new address[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            list[i - offset] = arr[i];
        }
    }

    function part(
        bytes32[] storage arr,
        uint256 offset,
        uint256 limit
    ) internal view returns (bytes32[] memory list) {
        uint256 to = _handleIncomingParametersForPart(arr.length, offset, limit);

        list = new bytes32[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            list[i - offset] = arr[i];
        }
    }

    function part(
        EnumerableSet.UintSet storage set,
        uint256 offset,
        uint256 limit
    ) internal view returns (uint256[] memory list) {
        uint256 to = _handleIncomingParametersForPart(set.length(), offset, limit);

        list = new uint256[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            list[i - offset] = set.at(i);
        }
    }

    function part(
        EnumerableSet.AddressSet storage set,
        uint256 offset,
        uint256 limit
    ) internal view returns (address[] memory list) {
        uint256 to = _handleIncomingParametersForPart(set.length(), offset, limit);

        list = new address[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            list[i - offset] = set.at(i);
        }
    }

    function part(
        EnumerableSet.Bytes32Set storage set,
        uint256 offset,
        uint256 limit
    ) internal view returns (bytes32[] memory list) {
        uint256 to = _handleIncomingParametersForPart(set.length(), offset, limit);

        list = new bytes32[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            list[i - offset] = set.at(i);
        }
    }

    function part(
        StringSet.Set storage set,
        uint256 offset,
        uint256 limit
    ) internal view returns (string[] memory list) {
        uint256 to = _handleIncomingParametersForPart(set.length(), offset, limit);

        list = new string[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            list[i - offset] = set.at(i);
        }
    }

    function _handleIncomingParametersForPart(
        uint256 length,
        uint256 offset,
        uint256 limit
    ) private pure returns (uint256 to) {
        to = offset + limit;

        if (to > length) to = length;
        if (offset > to) to = offset;
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

/**
 * This is a contract for storage and convenient retrieval of system parameters
 */
interface ISystemParameters {
    /// @notice The event that is emmited after updating of the rewards token address parameter
    /// @param _rewardsToken a new rewards token address value
    event RewardsTokenUpdated(address _rewardsToken);

    /// @notice The event that is emmited after updating of the donation address parameter
    /// @param _newDonationAddress a new donation address value
    event DonationAddressUpdated(address _newDonationAddress);

    /// @notice The event that is emmited after updating the parameter with the same name
    /// @param _newValue new liquidation boundary parameter value
    event LiquidationBoundaryUpdated(uint256 _newValue);

    /// @notice The event that is emmited after updating the parameter with the same name
    /// @param _newValue new stable pools availability parameter value
    event StablePoolsAvailabilityUpdated(bool _newValue);

    /// @notice The event that is emmited after updating the parameter with the same name
    /// @param _newValue new min currency amount parameter value
    event MinCurrencyAmountUpdated(uint256 _newValue);

    /// @notice The function that updates the rewards token address. Can update only if current rewards token address is zero address
    /// @dev Only owner of this contract can call this function
    /// @param _rewardsToken new value of the rewards token parameter
    function setRewardsTokenAddress(address _rewardsToken) external;

    /// @notice The function that updates the donation address
    /// @dev Only owner of this contract can call this function
    /// @param _newDonationAddress new value of the donation address parameter
    function setDonationAddress(address _newDonationAddress) external;

    /// @notice The function that updates the parameter of the same name to a new value
    /// @dev Only owner of this contract can call this function
    /// @param _newValue new value of the liquidation boundary parameter
    function setupLiquidationBoundary(uint256 _newValue) external;

    /// @notice The function that updates the parameter of the same name to a new value
    /// @dev Only owner of this contract can call this function
    /// @param _newValue new value of the stable pools availability parameter
    function setupStablePoolsAvailability(bool _newValue) external;

    /// @notice The function that updates the parameter of the same name
    /// @dev Only owner of this contract can call this function
    /// @param _newMinCurrencyAmount new value of the min currency amount parameter
    function setupMinCurrencyAmount(uint256 _newMinCurrencyAmount) external;

    ///@notice The function that returns the values of rewards token parameter
    ///@return current rewards token address
    function getRewardsTokenAddress() external view returns (address);

    ///@notice The function that returns the values of donation address parameter
    ///@return current donation address
    function getDonationAddress() external view returns (address);

    ///@notice The function that returns the values of liquidation boundary parameter
    ///@return current liquidation boundary parameter value
    function getLiquidationBoundary() external view returns (uint256);

    ///@notice The function that returns the values of stable pools availability parameter
    ///@return current stable pools availability parameter value
    function getStablePoolsAvailability() external view returns (bool);

    ///@notice The function that returns the value of the min currency amount parameter
    ///@return current min currency amount parameter value
    function getMinCurrencyAmount() external view returns (uint256);
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

/**
 * The central contract of the protocol, through which the main interaction goes.
 * Through this contract, liquidity is deposited, withdrawn, borrowed, repaid, claim distribution rewards, liquidated, and much more
 */
interface IDefiCore {
    /// @notice This event is emitted when a user update collateral value for specific pool
    /// @param _userAddr address of the user who updated the collateral value
    /// @param _assetKey key of the pool where the collateral value was updated
    /// @param _newValue a new collateral value
    event CollateralUpdated(address indexed _userAddr, bytes32 indexed _assetKey, bool _newValue);

    /// @notice This event is emitted when a user deposits liquidity into the pool
    /// @param _userAddr address of the user who deposited the liquidity
    /// @param _assetKey key of the pool where the liquidity was deposited
    /// @param _liquidityAmount number of tokens that were deposited
    event LiquidityAdded(
        address indexed _userAddr,
        bytes32 indexed _assetKey,
        uint256 _liquidityAmount
    );

    /// @notice This event is emitted when a user withdraws liquidity from the pool
    /// @param _userAddr address of the user who withdrawn the liquidity
    /// @param _assetKey key of the pool where the liquidity was withdrawn
    /// @param _liquidityAmount number of tokens that were withdrawn
    event LiquidityWithdrawn(
        address indexed _userAddr,
        bytes32 indexed _assetKey,
        uint256 _liquidityAmount
    );

    /// @notice This event is emitted when a user takes tokens on credit
    /// @param _borrower address of the user on whom the borrow is taken
    /// @param _recipient the address of the user to which the taken tokens will be sent
    /// @param _assetKey the key of the pool, the tokens of which will be taken on credit
    /// @param _borrowedAmount number of tokens to be taken on credit
    event Borrowed(
        address indexed _borrower,
        address _recipient,
        bytes32 indexed _assetKey,
        uint256 _borrowedAmount
    );

    /// @notice This event is emitted during the repayment of credit by the user
    /// @param _userAddr address of the user whose credit will be repaid
    /// @param _assetKey key of the pool in which the loan will be repaid
    /// @param _repaidAmount the amount of tokens for which the loan will be repaid
    event BorrowRepaid(
        address indexed _userAddr,
        bytes32 indexed _assetKey,
        uint256 _repaidAmount
    );

    /// @notice This event is emitted during the approve for delegated credit
    /// @param _userAddr address of the user who approved delegated borrow
    /// @param _assetKey the key of the pool in which the approve will be made
    /// @param _delegateeAddr address who is allowed to borrow the passed amount
    /// @param _newAmount the amount for which the approval is made
    event DelegateBorrowApproved(
        address indexed _userAddr,
        bytes32 indexed _assetKey,
        address _delegateeAddr,
        uint256 _newAmount
    );

    /// @notice This event is emitted after a successful donation
    /// @param _recipient an address of the donation recipient
    /// @param _amountInUSD a donation amount in USD
    event DonationCompleted(address _recipient, uint256 _amountInUSD);

    /// @notice This event is emitted when the user receives their distribution rewards
    /// @param _userAddr address of the user who receives distribution rewards
    /// @param _rewardAmount the amount of rewards the user will receive
    event DistributionRewardWithdrawn(address indexed _userAddr, uint256 _rewardAmount);

    /// @notice Function for pausing all user interactions with the system
    /// @dev Only contract owner can call this function
    function pause() external;

    /// @notice Function for unpausing all user interactions with the system
    /// @dev Only contract owner can call this function
    function unpause() external;

    /// @notice With this function you can change the value of the disabled of the asset as a collateral
    /// @param _assetKey pool key to update the value
    /// @param _isDisabled a flag that shows whether the asset will be disabled as a collateral
    function updateCollateral(bytes32 _assetKey, bool _isDisabled) external;

    /// @notice Function to update the compound rate with or without interval by pool key
    /// @param _assetKey key of the pool for which the compound rate will be updated
    /// @param _withInterval flag that shows whether to update the rate with or without interval
    /// @return new pool compound rate
    function updateCompoundRate(bytes32 _assetKey, bool _withInterval) external returns (uint256);

    /// @notice Function for adding liquidity by the user to a certain pool
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey key of the pool to which the liquidity will be added
    /// @param _liquidityAmount amount of tokens to add liquidity
    function addLiquidity(bytes32 _assetKey, uint256 _liquidityAmount) external payable;

    /// @notice Function for withdrawal of liquidity by the user from a certain pool
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey key of the pool from which the liquidity will be withdrawn
    /// @param _liquidityAmount the amount of tokens to withdraw liquidity
    /// @param _isMaxWithdraw the flag that shows whether to withdraw the maximum available amount or not
    function withdrawLiquidity(
        bytes32 _assetKey,
        uint256 _liquidityAmount,
        bool _isMaxWithdraw
    ) external;

    /// @notice The function is needed to allow addresses to borrow against your address for the desired amount
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey the key of the pool in which the approve will be made
    /// @param _approveAmount the amount for which the approval is made
    /// @param _delegateeAddr address who is allowed to borrow the passed amount
    /// @param _currentAllowance allowance before function execution
    function approveToDelegateBorrow(
        bytes32 _assetKey,
        uint256 _approveAmount,
        address _delegateeAddr,
        uint256 _currentAllowance
    ) external;

    /// @notice Function for taking credit tokens by the user in the desired pool
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey the key of the pool, the tokens of which will be taken on credit
    /// @param _borrowAmount the amount of tokens to be borrowed
    /// @param _recipientAddr token recipient address
    function borrowFor(
        bytes32 _assetKey,
        uint256 _borrowAmount,
        address _recipientAddr
    ) external;

    /// @notice Function for taking credit for the address that allowed you to do this
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey the key of the pool, the tokens of which will be taken on credit
    /// @param _borrowAmount the amount of tokens to be borrowed
    /// @param _borrowerAddr address to which the borrow will be taken
    function delegateBorrow(
        bytes32 _assetKey,
        uint256 _borrowAmount,
        address _borrowerAddr
    ) external;

    /// @notice Function for repayment of credit by the user in the desired pool
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey key of the pool in which the debt will be repaid
    /// @param _repayAmount the amount of tokens for which the borrow will be repaid
    /// @param _isMaxRepay a flag that shows whether or not to repay the debt by the maximum possible amount
    function repayBorrow(
        bytes32 _assetKey,
        uint256 _repayAmount,
        bool _isMaxRepay
    ) external payable;

    /// @notice Function for repayment of the desired user's credit
    /// @dev The function takes the amount with 18 decimals
    /// @param _assetKey key of the pool in which the debt will be repaid
    /// @param _repayAmount the amount of tokens for which the borrow will be repaid
    /// @param _recipientAddr the address of the user whose credit will be repaid
    /// @param _isMaxRepay a flag that shows whether or not to repay the debt by the maximum possible amount
    function delegateRepayBorrow(
        bytes32 _assetKey,
        uint256 _repayAmount,
        address _recipientAddr,
        bool _isMaxRepay
    ) external payable;

    /// @notice Function for liquidation users who must protocols funds
    /// @dev The function takes the amount with 18 decimals
    /// @param _userAddr address of the user to be liquidated
    /// @param _supplyAssetKey the pool key, which is the user's collateral
    /// @param _borrowAssetKey key of the pool where the user took the credit
    /// @param _liquidationAmount the amount of tokens that will go to pay off the debt of the liquidated user
    function liquidation(
        address _userAddr,
        bytes32 _supplyAssetKey,
        bytes32 _borrowAssetKey,
        uint256 _liquidationAmount
    ) external payable;

    /// @notice Function for getting the distribution reward from a specific pools or from the all pools
    /// @param _assetKeys an array of the keys of the pools from which the reward will be received
    /// @param _isAllPools the flag that shows whether all pools should be claimed
    /// @return _totalReward the amount of the total reward received
    function claimDistributionRewards(bytes32[] memory _assetKeys, bool _isAllPools)
        external
        returns (uint256 _totalReward);

    /// @notice Donates a certain amount of reserve funds from a certain pool
    /// @param _assetKey key of the required pool
    /// @param _amountToWithdraw amount for donate of reserve funds
    /// @param _isAllFunds flag to donate all reserve funds
    function donateReservedFunds(
        bytes32 _assetKey,
        uint256 _amountToWithdraw,
        bool _isAllFunds
    ) external;

    /// @notice Donate from all reserved funds from pools with pagination
    /// @param _offset offset for pagination
    /// @param _limit maximum number of elements for pagination
    /// @param _isAllPools flag for donate from all pools or not
    function donateAllReservedFunds(
        uint256 _offset,
        uint256 _limit,
        bool _isAllPools
    ) external;

    /// @notice Function to get information about the total amount of donations in dollars
    /// @return a total amount of donations in dollars
    function totalDonationInUSD() external view returns (uint256);

    /// @notice Function for getting information about the user's assets that are disabled as collateral
    /// @param _userAddr the address of the user for whom the information will be obtained
    /// @param _assetKey the key of the pool for which you want to get information
    /// @return true, if the asset disabled as collateral, false otherwise
    function disabledCollateralAssets(address _userAddr, bytes32 _assetKey)
        external
        view
        returns (bool);

    /// @notice Function to get the total amount of the user's deposit in dollars to all pools
    /// @param _userAddr address of the user for whom you want to get information
    /// @return _totalSupplyBalance total amount of the user's deposit in dollars
    function getTotalSupplyBalanceInUSD(address _userAddr)
        external
        view
        returns (uint256 _totalSupplyBalance);

    /// @notice Function for obtaining the amount that the user can maximally take on borrow
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return the amount of tokens that a user can maximal take on borrow
    function getMaxToBorrow(address _userAddr, bytes32 _assetKey) external view returns (uint256);

    /// @notice Function to get the amount by which the user can maximally repay the borrow
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return the amount of tokens by which the user can repay the debt at most
    function getMaxToRepay(address _userAddr, bytes32 _assetKey) external view returns (uint256);

    /// @notice Function for obtaining the amount that the user can maximally deposit
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return the number of tokens a user can deposit at most
    function getMaxToSupply(address _userAddr, bytes32 _assetKey) external view returns (uint256);

    /// @notice Function to get the maximum amount that the user can withdraw from the pool
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return the number of tokens that the user can withdraw from the pool at most
    function getMaxToWithdraw(address _userAddr, bytes32 _assetKey)
        external
        view
        returns (uint256);

    /// @notice Function to check if an asset is enabled as a collateral for a particular user
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return true, if passed asset enabled as collateral, false otherwise
    function isCollateralAssetEnabled(address _userAddr, bytes32 _assetKey)
        external
        view
        returns (bool);

    /// @notice Function to get the deposit amount with interest for the desired user in the passed pool
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return _userLiquidityAmount deposit amount with interest
    function getUserLiquidityAmount(address _userAddr, bytes32 _assetKey)
        external
        view
        returns (uint256 _userLiquidityAmount);

    /// @notice Function to get the borrow amount with interest for the desired user in the passed pool
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey the pool key for which the information is obtained
    /// @return _userBorrowedAmount borrow amount with interest
    function getUserBorrowedAmount(address _userAddr, bytes32 _assetKey)
        external
        view
        returns (uint256 _userBorrowedAmount);

    /// @notice Function to get the total amount of the user's borrows in dollars to all pools
    /// @param _userAddr address of the user for whom you want to get information
    /// @return _totalBorrowBalance total amount of the user's borrows in dollars
    function getTotalBorrowBalanceInUSD(address _userAddr)
        external
        view
        returns (uint256 _totalBorrowBalance);

    /// @notice Function for obtaining the current amount for which the user can take credit at most
    /// @param _userAddr address of the user for whom you want to get information
    /// @return _currentBorrowLimit a current user borrow limit in dollars
    function getCurrentBorrowLimitInUSD(address _userAddr)
        external
        view
        returns (uint256 _currentBorrowLimit);

    /// @notice Function for obtaining a new amount for which the user can take the maximum credit
    /// @dev The function takes the amount with 18 decimals
    /// @param _userAddr address of the user for whom you want to get information
    /// @param _assetKey key of the pool for which the new deposit amount will be applied
    /// @param _tokensAmount the number of tokens by which the calculation will be changed borrow limit
    /// @param _isAdding true, if the amount of tokens will be added, false otherwise
    /// @return a new user borrow limit in dollars
    function getNewBorrowLimitInUSD(
        address _userAddr,
        bytes32 _assetKey,
        uint256 _tokensAmount,
        bool _isAdding
    ) external view returns (uint256);

    /// @notice Function for obtaining available liquidity of the user and his debt
    /// @param _userAddr address of the user for whom you want to get information
    /// @return first parameter is available user liquidity is dollarse, second is a user debt
    function getAvailableLiquidity(address _userAddr) external view returns (uint256, uint256);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "./IBasicPool.sol";

/**
 * This contract calculates and stores information about the distribution of rewards to users for deposits and credits
 */
interface IRewardsDistribution {
    /// @notice The structure that contains information about the pool, which is necessary for the allocation of tokens
    /// @param rewardPerBlock reward for the block in tokens. Is common for deposits and credits
    /// @param supplyCumulativeSum cumulative sum on deposits
    /// @param borrowCumulativeSum cumulative sum on borrows
    /// @param lastUpdate time of the last cumulative sum update
    struct LiquidityPoolInfo {
        uint256 rewardPerBlock;
        uint256 supplyCumulativeSum;
        uint256 borrowCumulativeSum;
        uint256 lastUpdate;
    }

    /// @notice A structure that contains information about the user's cumulative amounts and his reward
    /// @param lastSupplyCumulativeSum cumulative sum on the deposit at the time of the last update
    /// @param lastBorrowCumulativeSum cumulative sum on the borrow at the time of the last update
    /// @param aggregatedReward aggregated user reward during the last update
    struct UserDistributionInfo {
        uint256 lastSupplyCumulativeSum;
        uint256 lastBorrowCumulativeSum;
        uint256 aggregatedReward;
    }

    /// @notice The system structure, which is needed to avoid stack overflow and stores the pool stats
    /// @param supplyRewardPerBlock current reward for the block, which will go to users who deposited tokens
    /// @param borrowRewardPerBlock the current reward for the block, which will go to users that took on credit
    /// @param totalSupplyPool total pool of tokens on deposit
    /// @param totalBorrowPool total pool of tokens borrowed
    struct LiquidityPoolStats {
        uint256 supplyRewardPerBlock;
        uint256 borrowRewardPerBlock;
        uint256 totalSupplyPool;
        uint256 totalBorrowPool;
    }

    /// @notice Function to update the cumulative sums for a particular user in the passed pool
    /// @dev Can call only by eligible contracts (DefiCore and LiquidityPools)
    /// @param _userAddr address of the user to whom the cumulative sums will be updated
    /// @param _liquidityPool required liquidity pool
    function updateCumulativeSums(address _userAddr, address _liquidityPool) external;

    /// @notice Function for withdraw accumulated user rewards. Rewards are updated before withdrawal
    /// @dev Can call only by eligible contracts (DefiCore and LiquidityPools)
    /// @param _assetKey the key of the desired pool, which will be used to calculate the reward
    /// @param _userAddr the address of the user for whom the reward will be counted
    /// @param _liquidityPool required liquidity pool
    /// @return _userReward total user reward from the passed pool
    function withdrawUserReward(
        bytes32 _assetKey,
        address _userAddr,
        address _liquidityPool
    ) external returns (uint256 _userReward);

    /// @notice Function to update block rewards for desired pools
    /// @dev Can call only by contract owner. The passed arrays must be of the same length
    /// @param _assetKeys array of pool identifiers
    /// @param _rewardsPerBlock array of new rewards per block
    function setupRewardsPerBlockBatch(
        bytes32[] calldata _assetKeys,
        uint256[] calldata _rewardsPerBlock
    ) external;

    /// @notice Returns the annual distribution rates for the desired pool
    /// @param _assetKey required liquidity pool identifier
    /// @return _supplyAPY annual distribution rate for users who deposited in the passed pool
    /// @return _borrowAPY annual distribution rate for users who took credit in the passed pool
    function getAPY(bytes32 _assetKey)
        external
        view
        returns (uint256 _supplyAPY, uint256 _borrowAPY);

    /// @notice Returns current total user reward from the passed pool
    /// @param _assetKey the key of the desired pool, which will be used to calculate the reward
    /// @param _userAddr the address of the user for whom the reward will be counted
    /// @param _liquidityPool required liquidity pool
    /// @return _userReward current total user reward from the passed pool
    function getUserReward(
        bytes32 _assetKey,
        address _userAddr,
        address _liquidityPool
    ) external view returns (uint256 _userReward);
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV2V3Interface.sol";

/**
 * This contract is responsible for obtaining asset prices from trusted oracles.
 * The contract code provides for a main oracle and a backup oracle, as well as the ability to switch all price fetches to a backup oracle
 */
interface IPriceManager {
    /// @notice The structure that contains the oracle address token for this token
    /// @param assetAddr address of the asset for which the oracles will be saved
    /// @param chainlinkOracle Chainlink oracle address for the desired asset
    struct PriceFeed {
        address assetAddr;
        AggregatorV2V3Interface chainlinkOracle;
    }

    /// @notice This event is emitted when a new oracle is added
    /// @param _assetKey the pool key for which oracles are added
    /// @param _chainlinkOracle Chainlink oracle address for the pool underlying asset
    event OracleAdded(bytes32 _assetKey, address _chainlinkOracle);

    /// @notice The function you need to add oracles for assets
    /// @dev Only SystemPoolsRegistry contract can call this function
    /// @param _assetKey the pool key for which oracles are added
    /// @param _assetAddr address of the asset for which the oracles will be added
    /// @param _chainlinkOracle the address of the chainlink oracle for the passed asset
    function addOracle(
        bytes32 _assetKey,
        address _assetAddr,
        address _chainlinkOracle
    ) external;

    /// @notice The function that returns the price for the asset for which oracles are saved
    /// @param _assetKey the key of the pool, for the asset for which the price will be obtained
    /// @return answer - the resulting token price, decimals - resulting token price decimals
    function getPrice(bytes32 _assetKey) external view returns (uint256, uint8);
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
pragma solidity ^0.8.0;

/* Example:
 *
 * using StringSet for StringSet.Set;
 *
 * StringSet.Set internal set;
 */
library StringSet {
    struct Set {
        string[] _values;
        mapping(string => uint256) _indexes;
    }

    /**
     *  @notice The function add value to set
     *  @param set the set object
     *  @param value the value to add
     */
    function add(Set storage set, string memory value) internal returns (bool) {
        if (!contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;

            return true;
        } else {
            return false;
        }
    }

    /**
     *  @notice The function remove value to set
     *  @param set the set object
     *  @param value the value to remove
     */
    function remove(Set storage set, string memory value) internal returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                string memory lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex;
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     *  @notice The function returns true if value in the set
     *  @param set the set object
     *  @param value the value to search in set
     */
    function contains(Set storage set, string memory value) internal view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     *  @notice The function returns length of set
     *  @param set the set object
     */
    function length(Set storage set) internal view returns (uint256) {
        return set._values.length;
    }

    /**
     *  @notice The function returns value from set by index
     *  @param set the set object
     *  @param index the index of slot in set
     */
    function at(Set storage set, uint256 index) internal view returns (string memory) {
        return set._values[index];
    }

    /**
     *  @notice The function that returns values the set stores, can be very expensive to call
     *  @param set the set object
     *  @return the memory array of values
     */
    function values(Set storage set) internal view returns (string[] memory) {
        return set._values;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AggregatorInterface.sol";
import "./AggregatorV3Interface.sol";

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface {}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}