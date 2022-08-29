// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";

import "./interfaces/IRegistry.sol";
import "./interfaces/ISystemParameters.sol";

import "./libraries/PureParameters.sol";

import "./common/Globals.sol";

contract SystemParameters is ISystemParameters, AbstractDependant {
    using PureParameters for PureParameters.Param;

    bytes32 public constant REWARDS_TOKEN_KEY = keccak256("REWARDS_TOKEN");
    bytes32 public constant DONATION_ADDRESS_KEY = keccak256("DONATION_ADDRESS");
    bytes32 public constant LIQUIDATION_BOUNDARY_KEY = keccak256("LIQUIDATION_BOUNDARY");
    bytes32 public constant STABLE_POOLS_AVAILABILITY_KEY = keccak256("STABLE_POOLS_AVAILABILITY");
    bytes32 public constant MIN_CURRENCY_AMOUNT_KEY = keccak256("MIN_CURRENCY_AMOUNT");

    address private systemOwnerAddr;

    mapping(bytes32 => PureParameters.Param) private _parameters;

    modifier onlySystemOwner() {
        require(
            msg.sender == systemOwnerAddr,
            "SystemParameters: Only system owner can call this function."
        );
        _;
    }

    function setDependencies(address _contractsRegistry) external override dependant {
        systemOwnerAddr = IRegistry(_contractsRegistry).getSystemOwner();
    }

    function setRewardsTokenAddress(address _rewardsToken) external override onlySystemOwner {
        PureParameters.Param memory _currentParam = _parameters[REWARDS_TOKEN_KEY];

        if (PureParameters.paramExists(_currentParam)) {
            require(
                _currentParam.getAddressFromParam() == address(0),
                "SystemParameters: Unable to change rewards token address."
            );
        }

        _parameters[REWARDS_TOKEN_KEY] = PureParameters.makeAddressParam(_rewardsToken);

        emit RewardsTokenUpdated(_rewardsToken);
    }

    function setDonationAddress(address _newDonationAddress) external override onlySystemOwner {
        require(
            _newDonationAddress != address(0),
            "SystemParameters: New donation address is zero."
        );

        _parameters[DONATION_ADDRESS_KEY] = PureParameters.makeAddressParam(_newDonationAddress);

        emit DonationAddressUpdated(_newDonationAddress);
    }

    function setupLiquidationBoundary(uint256 _newValue) external override onlySystemOwner {
        require(
            _newValue >= ONE_PERCENT * 50 && _newValue <= ONE_PERCENT * 80,
            "SystemParameters: The new value of the liquidation boundary is invalid."
        );

        _parameters[LIQUIDATION_BOUNDARY_KEY] = PureParameters.makeUintParam(_newValue);

        emit LiquidationBoundaryUpdated(_newValue);
    }

    function setupStablePoolsAvailability(bool _newValue) external override onlySystemOwner {
        _parameters[STABLE_POOLS_AVAILABILITY_KEY] = PureParameters.makeBoolParam(_newValue);

        emit StablePoolsAvailabilityUpdated(_newValue);
    }

    function setupMinCurrencyAmount(uint256 _newMinCurrencyAmount)
        external
        override
        onlySystemOwner
    {
        _parameters[MIN_CURRENCY_AMOUNT_KEY] = PureParameters.makeUintParam(_newMinCurrencyAmount);

        emit MinCurrencyAmountUpdated(_newMinCurrencyAmount);
    }

    function getDonationAddress() external view override returns (address) {
        return _getParam(DONATION_ADDRESS_KEY).getAddressFromParam();
    }

    function getRewardsTokenAddress() external view override returns (address) {
        return _getParam(REWARDS_TOKEN_KEY).getAddressFromParam();
    }

    function getLiquidationBoundary() external view override returns (uint256) {
        return _getParam(LIQUIDATION_BOUNDARY_KEY).getUintFromParam();
    }

    function getStablePoolsAvailability() external view override returns (bool) {
        return _getParam(STABLE_POOLS_AVAILABILITY_KEY).getBoolFromParam();
    }

    function getMinCurrencyAmount() external view override returns (uint256) {
        return _getParam(MIN_CURRENCY_AMOUNT_KEY).getUintFromParam();
    }

    function _getParam(bytes32 _paramKey) internal view returns (PureParameters.Param memory) {
        require(
            PureParameters.paramExists(_parameters[_paramKey]),
            "SystemParameters: Param for this key doesn't exist."
        );

        return _parameters[_paramKey];
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