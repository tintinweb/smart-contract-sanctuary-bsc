// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";

import "./interfaces/IRegistry.sol";
import "./interfaces/ISystemParameters.sol";
import "./interfaces/IAssetParameters.sol";
import "./interfaces/ISystemPoolsRegistry.sol";
import "./interfaces/IBasicPool.sol";
import "./interfaces/IPriceManager.sol";

import "./libraries/PureParameters.sol";

import "./common/Globals.sol";

contract AssetParameters is IAssetParameters, AbstractDependant {
    using PureParameters for PureParameters.Param;
    using MathUpgradeable for uint256;

    bytes32 public constant FREEZE_KEY = keccak256("FREEZE");
    bytes32 public constant ENABLE_COLLATERAL_KEY = keccak256("ENABLE_COLLATERAL");

    bytes32 public constant BASE_PERCENTAGE_KEY = keccak256("BASE_PERCENTAGE");
    bytes32 public constant FIRST_SLOPE_KEY = keccak256("FIRST_SLOPE");
    bytes32 public constant SECOND_SLOPE_KEY = keccak256("SECOND_SLOPE");
    bytes32 public constant UTILIZATION_BREAKING_POINT_KEY =
        keccak256("UTILIZATION_BREAKING_POINT");
    bytes32 public constant MAX_UTILIZATION_RATIO_KEY = keccak256("MAX_UTILIZATION_RATIO");
    bytes32 public constant LIQUIDATION_DISCOUNT_KEY = keccak256("LIQUIDATION_DISCOUNT");

    bytes32 public constant MIN_SUPPLY_DISTRIBUTION_PART_KEY =
        keccak256("MIN_SUPPLY_DISTRIBUTION_PART");
    bytes32 public constant MIN_BORROW_DISTRIBUTION_PART_KEY =
        keccak256("MIN_BORROW_DISTRIBUTION_PART");

    bytes32 public constant COL_RATIO_KEY = keccak256("COL_RATIO");
    bytes32 public constant RESERVE_FACTOR_KEY = keccak256("RESERVE_FACTOR");

    bytes32 public constant ANNUAL_BORROW_RATE_KEY = keccak256("ANNUAL_BORROW_RATE");

    address private systemOwnerAddr;
    ISystemParameters private systemParameters;
    ISystemPoolsRegistry private systemPoolsRegistry;
    IPriceManager private priceManager;

    mapping(bytes32 => mapping(bytes32 => PureParameters.Param)) private _parameters;

    modifier onlyExists(bytes32 _assetKey) {
        require(
            systemPoolsRegistry.onlyExistingPool(_assetKey),
            "AssetParameters: Asset doesn't exist."
        );
        _;
    }

    modifier onlySystemOwner() {
        require(
            msg.sender == systemOwnerAddr,
            "AssetParameters: Only system owner can call this function."
        );
        _;
    }

    function setDependencies(address _contractsRegistry) external override dependant {
        IRegistry _registry = IRegistry(_contractsRegistry);

        systemOwnerAddr = _registry.getSystemOwner();
        systemParameters = ISystemParameters(_registry.getSystemParametersContract());
        systemPoolsRegistry = ISystemPoolsRegistry(_registry.getSystemPoolsRegistryContract());
        priceManager = IPriceManager(_registry.getPriceManagerContract());
    }

    function setPoolInitParams(bytes32 _assetKey, bool _isCollateral) external override {
        require(
            address(systemPoolsRegistry) == msg.sender,
            "AssetParameters: Caller not a SystemPoolsRegistry."
        );

        _parameters[_assetKey][FREEZE_KEY] = PureParameters.makeBoolParam(false);
        emit FreezeParamUpdated(_assetKey, false);

        _parameters[_assetKey][ENABLE_COLLATERAL_KEY] = PureParameters.makeBoolParam(
            _isCollateral
        );
        emit CollateralParamUpdated(_assetKey, _isCollateral);
    }

    function setupAnnualBorrowRate(bytes32 _assetKey, uint256 _newAnnualBorrowRate)
        external
        override
        onlySystemOwner
        onlyExists(_assetKey)
    {
        require(
            systemParameters.getStablePoolsAvailability(),
            "AssetParameters: Stable pools unavailable."
        );
        (address _poolAddr, ISystemPoolsRegistry.PoolType _poolType) = systemPoolsRegistry
            .poolsInfo(_assetKey);

        require(
            _poolType == ISystemPoolsRegistry.PoolType.STABLE_POOL,
            "AssetParameters: Incorrect pool type."
        );

        require(
            _newAnnualBorrowRate <= ONE_PERCENT * 25,
            "AssetParameters: Annual borrow rate is higher than possible."
        );

        if (PureParameters.paramExists(_parameters[_assetKey][ANNUAL_BORROW_RATE_KEY])) {
            IBasicPool(_poolAddr).updateCompoundRate(false);
        }

        _parameters[_assetKey][ANNUAL_BORROW_RATE_KEY] = PureParameters.makeUintParam(
            _newAnnualBorrowRate
        );

        emit AnnualBorrowRateUpdated(_assetKey, _newAnnualBorrowRate);
    }

    function setupMainParameters(bytes32 _assetKey, MainPoolParams calldata _mainParams)
        external
        override
        onlySystemOwner
        onlyExists(_assetKey)
    {
        _setupMainParameters(_assetKey, _mainParams);
    }

    function setupInterestRateModel(bytes32 _assetKey, InterestRateParams calldata _interestParams)
        external
        override
        onlySystemOwner
        onlyExists(_assetKey)
    {
        _setupInterestRateParams(_assetKey, _interestParams);
    }

    function setupDistributionsMinimums(
        bytes32 _assetKey,
        DistributionMinimums calldata _distrMinimums
    ) external override onlySystemOwner onlyExists(_assetKey) {
        _setupDistributionsMinimums(_assetKey, _distrMinimums);
    }

    function setupAllParameters(bytes32 _assetKey, AllPoolParams calldata _poolParams)
        external
        override
        onlySystemOwner
        onlyExists(_assetKey)
    {
        _setupInterestRateParams(_assetKey, _poolParams.interestRateParams);
        _setupMainParameters(_assetKey, _poolParams.mainParams);
        _setupDistributionsMinimums(_assetKey, _poolParams.distrMinimums);
    }

    function freeze(bytes32 _assetKey) external override onlySystemOwner onlyExists(_assetKey) {
        _parameters[_assetKey][FREEZE_KEY] = PureParameters.makeBoolParam(true);

        emit FreezeParamUpdated(_assetKey, true);
    }

    function enableCollateral(bytes32 _assetKey)
        external
        override
        onlySystemOwner
        onlyExists(_assetKey)
    {
        _parameters[_assetKey][ENABLE_COLLATERAL_KEY] = PureParameters.makeBoolParam(true);

        emit CollateralParamUpdated(_assetKey, true);
    }

    function isPoolFrozen(bytes32 _assetKey) external view override returns (bool) {
        return _getParam(_assetKey, FREEZE_KEY).getBoolFromParam();
    }

    function isAvailableAsCollateral(bytes32 _assetKey) external view override returns (bool) {
        return _getParam(_assetKey, ENABLE_COLLATERAL_KEY).getBoolFromParam();
    }

    function getAnnualBorrowRate(bytes32 _assetKey) external view override returns (uint256) {
        return _getParam(_assetKey, ANNUAL_BORROW_RATE_KEY).getUintFromParam();
    }

    function getMainPoolParams(bytes32 _assetKey)
        external
        view
        override
        returns (MainPoolParams memory)
    {
        return
            MainPoolParams(
                _getParam(_assetKey, COL_RATIO_KEY).getUintFromParam(),
                _getParam(_assetKey, RESERVE_FACTOR_KEY).getUintFromParam(),
                _getParam(_assetKey, LIQUIDATION_DISCOUNT_KEY).getUintFromParam(),
                _getParam(_assetKey, MAX_UTILIZATION_RATIO_KEY).getUintFromParam()
            );
    }

    function getInterestRateParams(bytes32 _assetKey)
        external
        view
        override
        returns (InterestRateParams memory)
    {
        return
            InterestRateParams(
                _getParam(_assetKey, BASE_PERCENTAGE_KEY).getUintFromParam(),
                _getParam(_assetKey, FIRST_SLOPE_KEY).getUintFromParam(),
                _getParam(_assetKey, SECOND_SLOPE_KEY).getUintFromParam(),
                _getParam(_assetKey, UTILIZATION_BREAKING_POINT_KEY).getUintFromParam()
            );
    }

    function getDistributionMinimums(bytes32 _assetKey)
        external
        view
        override
        returns (DistributionMinimums memory)
    {
        return
            DistributionMinimums(
                _getParam(_assetKey, MIN_SUPPLY_DISTRIBUTION_PART_KEY).getUintFromParam(),
                _getParam(_assetKey, MIN_BORROW_DISTRIBUTION_PART_KEY).getUintFromParam()
            );
    }

    function getColRatio(bytes32 _assetKey) external view override returns (uint256) {
        return _getParam(_assetKey, COL_RATIO_KEY).getUintFromParam();
    }

    function getReserveFactor(bytes32 _assetKey) external view override returns (uint256) {
        return _getParam(_assetKey, RESERVE_FACTOR_KEY).getUintFromParam();
    }

    function getLiquidationDiscount(bytes32 _assetKey) external view override returns (uint256) {
        return _getParam(_assetKey, LIQUIDATION_DISCOUNT_KEY).getUintFromParam();
    }

    function getMaxUtilizationRatio(bytes32 _assetKey) external view override returns (uint256) {
        return _getParam(_assetKey, MAX_UTILIZATION_RATIO_KEY).getUintFromParam();
    }

    function _setupInterestRateParams(
        bytes32 _assetKey,
        InterestRateParams calldata _interestParams
    ) internal {
        require(
            _interestParams.basePercentage <= ONE_PERCENT * 3,
            "AssetParameters: The new value of the base percentage is invalid."
        );
        require(
            _interestParams.firstSlope >= ONE_PERCENT * 3 &&
                _interestParams.firstSlope <= ONE_PERCENT * 20,
            "AssetParameters: The new value of the first slope is invalid."
        );
        require(
            _interestParams.secondSlope >= ONE_PERCENT * 50 &&
                _interestParams.secondSlope <= DECIMAL,
            "AssetParameters: The new value of the second slope is invalid."
        );
        require(
            _interestParams.utilizationBreakingPoint >= ONE_PERCENT * 60 &&
                _interestParams.utilizationBreakingPoint <= ONE_PERCENT * 90,
            "AssetParameters: The new value of the utilization breaking point is invalid."
        );

        _parameters[_assetKey][BASE_PERCENTAGE_KEY] = PureParameters.makeUintParam(
            _interestParams.basePercentage
        );
        _parameters[_assetKey][FIRST_SLOPE_KEY] = PureParameters.makeUintParam(
            _interestParams.firstSlope
        );
        _parameters[_assetKey][SECOND_SLOPE_KEY] = PureParameters.makeUintParam(
            _interestParams.secondSlope
        );
        _parameters[_assetKey][UTILIZATION_BREAKING_POINT_KEY] = PureParameters.makeUintParam(
            _interestParams.utilizationBreakingPoint
        );

        emit InterestRateParamsUpdated(
            _assetKey,
            _interestParams.basePercentage,
            _interestParams.firstSlope,
            _interestParams.secondSlope,
            _interestParams.utilizationBreakingPoint
        );
    }

    function _setupMainParameters(bytes32 _assetKey, MainPoolParams calldata _mainParams)
        internal
    {
        require(
            _mainParams.collateralizationRatio >= ONE_PERCENT * 111 &&
                _mainParams.collateralizationRatio <= ONE_PERCENT * 200,
            "AssetParameters: The new value of the collateralization ratio is invalid."
        );
        require(
            _mainParams.reserveFactor >= ONE_PERCENT * 10 &&
                _mainParams.reserveFactor <= ONE_PERCENT * 35,
            "AssetParameters: The new value of the reserve factor is invalid."
        );
        require(
            _mainParams.liquidationDiscount <= ONE_PERCENT * 10,
            "AssetParameters: The new value of the liquidation discount is invalid."
        );
        require(
            _mainParams.maxUtilizationRatio >= ONE_PERCENT * 94 &&
                _mainParams.maxUtilizationRatio <= ONE_PERCENT * 97,
            "AssetParameters: The new value of the max utilization ratio is invalid."
        );

        _parameters[_assetKey][COL_RATIO_KEY] = PureParameters.makeUintParam(
            _mainParams.collateralizationRatio
        );
        _parameters[_assetKey][RESERVE_FACTOR_KEY] = PureParameters.makeUintParam(
            _mainParams.reserveFactor
        );
        _parameters[_assetKey][LIQUIDATION_DISCOUNT_KEY] = PureParameters.makeUintParam(
            _mainParams.liquidationDiscount
        );
        _parameters[_assetKey][MAX_UTILIZATION_RATIO_KEY] = PureParameters.makeUintParam(
            _mainParams.maxUtilizationRatio
        );

        emit MainParamsUpdated(
            _assetKey,
            _mainParams.collateralizationRatio,
            _mainParams.reserveFactor,
            _mainParams.liquidationDiscount,
            _mainParams.maxUtilizationRatio
        );
    }

    function _setupDistributionsMinimums(
        bytes32 _assetKey,
        DistributionMinimums calldata _distrMinimums
    ) internal {
        require(
            _distrMinimums.minSupplyDistrPart >= ONE_PERCENT * 5 &&
                _distrMinimums.minSupplyDistrPart <= ONE_PERCENT * 15,
            "AssetParameters: The new value of the minimum supply part is invalid."
        );
        require(
            _distrMinimums.minBorrowDistrPart >= ONE_PERCENT * 5 &&
                _distrMinimums.minBorrowDistrPart <= ONE_PERCENT * 15,
            "AssetParameters: The new value of the minimum borrow part is invalid."
        );

        _parameters[_assetKey][MIN_SUPPLY_DISTRIBUTION_PART_KEY] = PureParameters.makeUintParam(
            _distrMinimums.minSupplyDistrPart
        );
        _parameters[_assetKey][MIN_BORROW_DISTRIBUTION_PART_KEY] = PureParameters.makeUintParam(
            _distrMinimums.minBorrowDistrPart
        );

        emit DistributionMinimumsUpdated(
            _assetKey,
            _distrMinimums.minSupplyDistrPart,
            _distrMinimums.minBorrowDistrPart
        );
    }

    function _getParam(bytes32 _assetKey, bytes32 _paramKey)
        internal
        view
        returns (PureParameters.Param memory)
    {
        require(
            PureParameters.paramExists(_parameters[_assetKey][_paramKey]),
            "AssetParameters: Param for this asset doesn't exist."
        );

        return _parameters[_assetKey][_paramKey];
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
library EnumerableSetUpgradeable {
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
library MathUpgradeable {
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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

/**
 * This library is used to conveniently store and retrieve parameters of different types
 */
library PureParameters {
    /// @notice This is an enumeration with available parameter types
    /// @param NOT_EXIST parameter type is not specified
    /// @param UINT uint256 parameter type
    /// @param ADDRESS address parameter type
    /// @param BYTES32 bytes32 parameter type
    /// @param BOOL bool parameter type
    enum Types {
        NOT_EXIST,
        UINT,
        ADDRESS,
        BYTES32,
        BOOL
    }

    /// @notice This is a structure with fields of available types
    /// @param uintParam uint256 struct field
    /// @param addressParam address struct field
    /// @param bytes32Param bytes32 struct field
    /// @param boolParam bool struct field
    /// @param currentType current parameter type
    struct Param {
        bytes32 param;
        Types currentType;
    }

    /// @notice Function for creating a type Param structure with a type uint256 parameter
    /// @param _number uint256 parameter value
    /// @return a struct with Param type and uint256 parameter value
    function makeUintParam(uint256 _number) internal pure returns (Param memory) {
        return Param(bytes32(_number), Types.UINT);
    }

    /// @notice Function for creating a type Param structure with a type address parameter
    /// @param _address address parameter value
    /// @return a struct with Param type and address parameter value
    function makeAddressParam(address _address) internal pure returns (Param memory) {
        return Param(bytes32(uint256(uint160(_address))), Types.ADDRESS);
    }

    /// @notice Function for creating a type Param structure with a type bytes32 parameter
    /// @param _hash bytes32 parameter value
    /// @return a struct with Param type and bytes32 parameter value
    function makeBytes32Param(bytes32 _hash) internal pure returns (Param memory) {
        return Param(_hash, Types.BYTES32);
    }

    /// @notice Function for creating a type Param structure with a type bool parameter
    /// @param _bool bool parameter value
    /// @return a struct with Param type and bool parameter value
    function makeBoolParam(bool _bool) internal pure returns (Param memory) {
        return Param(bytes32(uint256(_bool ? 1 : 0)), Types.BOOL);
    }

    /// @notice Function for getting a value of type uint256 from structure Param
    /// @param _param object of the structure from which the parameter will be obtained
    /// @return a uint256 parameter
    function getUintFromParam(Param memory _param) internal pure returns (uint256) {
        require(_param.currentType == Types.UINT, "PureParameters: Parameter not contain uint.");

        return uint256(_param.param);
    }

    /// @notice Function for getting a value of type address from structure Param
    /// @param _param object of the structure from which the parameter will be obtained
    /// @return a address parameter
    function getAddressFromParam(Param memory _param) internal pure returns (address) {
        require(
            _param.currentType == Types.ADDRESS,
            "PureParameters: Parameter not contain address."
        );

        return address(uint160(uint256(_param.param)));
    }

    /// @notice Function for getting a value of type bytes32 from structure Param
    /// @param _param object of the structure from which the parameter will be obtained
    /// @return a bytes32 parameter
    function getBytes32FromParam(Param memory _param) internal pure returns (bytes32) {
        require(
            _param.currentType == Types.BYTES32,
            "PureParameters: Parameter not contain bytes32."
        );

        return _param.param;
    }

    /// @notice Function for getting a value of type bool from structure Param
    /// @param _param object of the structure from which the parameter will be obtained
    /// @return a bool parameter
    function getBoolFromParam(Param memory _param) internal pure returns (bool) {
        require(_param.currentType == Types.BOOL, "PureParameters: Parameter not contain bool.");

        return uint256(_param.param) == 1 ? true : false;
    }

    /// @notice Function to check if the parameter exists
    /// @param _param structure with parameters that will be checked
    /// @return true, if the param exists, false otherwise
    function paramExists(Param memory _param) internal pure returns (bool) {
        return (_param.currentType != Types.NOT_EXIST);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

uint256 constant ONE_PERCENT = 10**25;
uint256 constant DECIMAL = ONE_PERCENT * 100;

uint8 constant STANDARD_DECIMALS = 18;
uint256 constant ONE_TOKEN = 10**STANDARD_DECIMALS;

uint256 constant BLOCKS_PER_DAY = 4900;
uint256 constant BLOCKS_PER_YEAR = BLOCKS_PER_DAY * 365;

uint8 constant PRICE_DECIMALS = 8;

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