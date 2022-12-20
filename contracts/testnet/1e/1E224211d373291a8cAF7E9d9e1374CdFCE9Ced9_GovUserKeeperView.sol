// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import "./AbstractDependant.sol";
import "./ProxyUpgrader.sol";

/**
 *  @notice The ContractsRegistry module
 *
 *  The purpose of this module is to provide an organized registry of the project's smartcontracts
 *  together with the upgradeability and dependency injection mechanisms.
 *
 *  The ContractsRegistry should be used as the highest level smartcontract that is aware of any other
 *  contract present in the system. The contracts that demand other system's contracts would then inherit
 *  special `AbstractDependant` contract and override `setDependencies()` function to enable ContractsRegistry
 *  to inject dependencies into them.
 *
 *  The ContractsRegistry will help with the following usecases:
 *
 *  1) Making the system upgradeable
 *  2) Making the system contracts-interchangeable
 *  3) Simplifying the contracts management and deployment
 *
 *  The ContractsRegistry acts as a Transparent proxy deployer. One can add proxy-compatible implementations to the registry
 *  and deploy proxies to them. Then these proxies can be upgraded easily using the ContractsRegistry.
 *  The ContractsRegistry itself can be deployed behind a proxy as well.
 *
 *  The dependency injection system may come in handy when one wants to substitute a contract `A` with a contract `B`
 *  (for example contract `A` got exploited) without a necessity of redeploying the whole system. One would just add
 *  a new `B` contract to a ContractsRegistry and re-inject all the required dependencies. Dependency injection mechanism
 *  also works with factories.
 *
 *  The management is simplified because all of the contracts are now located in a single place.
 */
abstract contract AbstractContractsRegistry is Initializable {
    ProxyUpgrader private _proxyUpgrader;

    mapping(string => address) private _contracts;
    mapping(address => bool) private _isProxy;

    event AddedContract(string name, address contractAddress, bool isProxy);
    event RemovedContract(string name);

    /**
     *  @notice The proxy initializer function
     */
    function __ContractsRegistry_init() internal onlyInitializing {
        _proxyUpgrader = new ProxyUpgrader();
    }

    /**
     *  @notice The function that returns an associated contract with the name
     *  @param name the name of the contract
     *  @return the address of the contract
     */
    function getContract(string memory name) public view returns (address) {
        address contractAddress = _contracts[name];

        require(contractAddress != address(0), "ContractsRegistry: This mapping doesn't exist");

        return contractAddress;
    }

    /**
     *  @notice The function that check if a contract with a given name has been added
     *  @param name the name of the contract
     *  @return true if the contract is present in the registry
     */
    function hasContract(string memory name) public view returns (bool) {
        return _contracts[name] != address(0);
    }

    /**
     *  @notice The function that returns the admin of the added proxy contracts
     *  @return the proxy admin address
     */
    function getProxyUpgrader() public view returns (address) {
        return address(_proxyUpgrader);
    }

    /**
     *  @notice The function that returns an implementation of the given proxy contract
     *  @param name the name of the contract
     *  @return the implementation address
     */
    function getImplementation(string memory name) public view returns (address) {
        address contractProxy = _contracts[name];

        require(contractProxy != address(0), "ContractsRegistry: This mapping doesn't exist");
        require(_isProxy[contractProxy], "ContractsRegistry: Not a proxy contract");

        return _proxyUpgrader.getImplementation(contractProxy);
    }

    /**
     *  @notice The function that injects the dependencies into the given contract
     *  @param name the name of the contract
     */
    function _injectDependencies(string memory name) internal {
        address contractAddress = _contracts[name];

        require(contractAddress != address(0), "ContractsRegistry: This mapping doesn't exist");

        AbstractDependant dependant = AbstractDependant(contractAddress);
        dependant.setDependencies(address(this));
    }

    /**
     *  @notice The function to upgrade added proxy contract with a new implementation
     *  @param name the name of the proxy contract
     *  @param newImplementation the new implementation the proxy should be upgraded to
     *
     *  It is the Owner's responsibility to ensure the compatibility between implementations
     */
    function _upgradeContract(string memory name, address newImplementation) internal {
        _upgradeContractAndCall(name, newImplementation, bytes(""));
    }

    /**
     *  @notice The function to upgrade added proxy contract with a new implementation, providing data
     *  @param name the name of the proxy contract
     *  @param newImplementation the new implementation the proxy should be upgraded to
     *  @param data the data that the new implementation will be called with. This can be an ABI encoded function call
     *
     *  It is the Owner's responsibility to ensure the compatibility between implementations
     */
    function _upgradeContractAndCall(
        string memory name,
        address newImplementation,
        bytes memory data
    ) internal {
        address contractToUpgrade = _contracts[name];

        require(contractToUpgrade != address(0), "ContractsRegistry: This mapping doesn't exist");
        require(_isProxy[contractToUpgrade], "ContractsRegistry: Not a proxy contract");

        _proxyUpgrader.upgrade(contractToUpgrade, newImplementation, data);
    }

    /**
     *  @notice The function to add pure contracts to the ContractsRegistry. These should either be
     *  the contracts the system does not have direct upgradeability control over, or the contracts that are not upgradeable
     *  @param name the name to associate the contract with
     *  @param contractAddress the address of the contract
     */
    function _addContract(string memory name, address contractAddress) internal {
        require(contractAddress != address(0), "ContractsRegistry: Null address is forbidden");

        _contracts[name] = contractAddress;

        emit AddedContract(name, contractAddress, false);
    }

    /**
     *  @notice The function to add the contracts and deploy the proxy above them. It should be used to add
     *  contract that the ContractsRegistry should be able to upgrade
     *  @param name the name to associate the contract with
     *  @param contractAddress the address of the implementation
     */
    function _addProxyContract(string memory name, address contractAddress) internal {
        require(contractAddress != address(0), "ContractsRegistry: Null address is forbidden");

        address proxyAddr = address(
            new TransparentUpgradeableProxy(contractAddress, address(_proxyUpgrader), "")
        );

        _contracts[name] = proxyAddr;
        _isProxy[proxyAddr] = true;

        emit AddedContract(name, proxyAddr, true);
    }

    /**
     *  @notice The function to add the already deployed proxy to the ContractsRegistry. This might be used
     *  when the system migrates to a new ContractRegistry. This means that the new ProxyUpgrader must have the
     *  credentials to upgrade the added proxies
     *  @param name the name to associate the contract with
     *  @param contractAddress the address of the proxy
     */
    function _justAddProxyContract(string memory name, address contractAddress) internal {
        require(contractAddress != address(0), "ContractsRegistry: Null address is forbidden");

        _contracts[name] = contractAddress;
        _isProxy[contractAddress] = true;

        emit AddedContract(name, contractAddress, true);
    }

    /**
     *  @notice The function to remove the contract from the ContractsRegistry
     *  @param name the associated name with the contract
     */
    function _removeContract(string memory name) internal {
        require(_contracts[name] != address(0), "ContractsRegistry: This mapping doesn't exist");

        delete _isProxy[_contracts[name]];
        delete _contracts[name];

        emit RemovedContract(name);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../AbstractContractsRegistry.sol";

/**
 *  @notice The Ownable preset of ContractsRegistry
 */
contract OwnableContractsRegistry is AbstractContractsRegistry, OwnableUpgradeable {
    function __OwnableContractsRegistry_init() public initializer {
        __Ownable_init();
        __ContractsRegistry_init();
    }

    function injectDependencies(string calldata name) external onlyOwner {
        _injectDependencies(name);
    }

    function upgradeContract(string calldata name, address newImplementation) external onlyOwner {
        _upgradeContract(name, newImplementation);
    }

    function upgradeContractAndCall(
        string calldata name,
        address newImplementation,
        bytes calldata data
    ) external onlyOwner {
        _upgradeContractAndCall(name, newImplementation, data);
    }

    function addContract(string calldata name, address contractAddress) external onlyOwner {
        _addContract(name, contractAddress);
    }

    function addProxyContract(string calldata name, address contractAddress) external onlyOwner {
        _addProxyContract(name, contractAddress);
    }

    function justAddProxyContract(
        string calldata name,
        address contractAddress
    ) external onlyOwner {
        _justAddProxyContract(name, contractAddress);
    }

    function removeContract(string calldata name) external onlyOwner {
        _removeContract(name);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 *  @notice The ContractsRegistry module
 *
 *  This is the helper contract that is used by an AbstractContractsRegistry as a proxy admin.
 *  It is essential to distinguish between the admin and the registry due to the Transparent proxies nature
 */
contract ProxyUpgrader {
    using Address for address;

    address private immutable _owner;

    event Upgraded(address indexed proxy, address indexed implementation);

    modifier onlyOwner() {
        require(_owner == msg.sender, "ProxyUpgrader: Not an owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function upgrade(address what, address to, bytes calldata data) external onlyOwner {
        if (data.length > 0) {
            TransparentUpgradeableProxy(payable(what)).upgradeToAndCall(to, data);
        } else {
            TransparentUpgradeableProxy(payable(what)).upgradeTo(to);
        }

        emit Upgraded(what, to);
    }

    function getImplementation(address what) external view onlyOwner returns (address) {
        // bytes4(keccak256("implementation()")) == 0x5c60da1b
        (bool success, bytes memory returndata) = address(what).staticcall(hex"5c60da1b");
        require(success);

        return abi.decode(returndata, (address));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 *  @notice A simple library to work with arrays
 */
library ArrayHelper {
    function reverse(uint256[] memory arr) internal pure returns (uint256[] memory reversed) {
        reversed = new uint256[](arr.length);
        uint256 i = arr.length;

        while (i > 0) {
            i--;
            reversed[arr.length - 1 - i] = arr[i];
        }
    }

    function reverse(address[] memory arr) internal pure returns (address[] memory reversed) {
        reversed = new address[](arr.length);
        uint256 i = arr.length;

        while (i > 0) {
            i--;
            reversed[arr.length - 1 - i] = arr[i];
        }
    }

    function reverse(string[] memory arr) internal pure returns (string[] memory reversed) {
        reversed = new string[](arr.length);
        uint256 i = arr.length;

        while (i > 0) {
            i--;
            reversed[arr.length - 1 - i] = arr[i];
        }
    }

    function insert(
        uint256[] memory to,
        uint256 index,
        uint256[] memory what
    ) internal pure returns (uint256) {
        for (uint256 i = 0; i < what.length; i++) {
            to[index + i] = what[i];
        }

        return index + what.length;
    }

    function insert(
        address[] memory to,
        uint256 index,
        address[] memory what
    ) internal pure returns (uint256) {
        for (uint256 i = 0; i < what.length; i++) {
            to[index + i] = what[i];
        }

        return index + what.length;
    }

    function insert(
        string[] memory to,
        uint256 index,
        string[] memory what
    ) internal pure returns (uint256) {
        for (uint256 i = 0; i < what.length; i++) {
            to[index + i] = what[i];
        }

        return index + what.length;
    }

    function asArray(uint256 elem) internal pure returns (uint256[] memory array) {
        array = new uint256[](1);
        array[0] = elem;
    }

    function asArray(address elem) internal pure returns (address[] memory array) {
        array = new address[](1);
        array[0] = elem;
    }

    function asArray(string memory elem) internal pure returns (string[] memory array) {
        array = new string[](1);
        array[0] = elem;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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
pragma solidity ^0.8.4;

/**
 *  @notice This library is used to convert numbers that use token's N decimals to M decimals.
 *  Comes extremely handy with standardizing the business logic that is intended to work with many different ERC20 tokens
 *  that have different precision (decimals). One can perform calculations with 18 decimals only and resort to convertion
 *  only when the payouts (or interactions) with the actual tokes have to be made.
 *
 *  The best usage scenario involves accepting and calculating values with 18 decimals throughout the project, despite the tokens decimals.
 *
 *  Also it is recommended to call `round18()` function on the first execution line in order to get rid of the
 *  trailing numbers if the destination decimals are less than 18
 *
 *  Example:
 *
 *  contract Taker {
 *      ERC20 public USDC;
 *      uint256 public paid;
 *
 *      . . .
 *
 *      function pay(uint256 amount) external {
 *          uint256 decimals = USDC.decimals();
 *          amount = amount.round18(decimals);
 *
 *          paid += amount;
 *          USDC.transferFrom(msg.sender, address(this), amount.from18(decimals));
 *      }
 *  }
 */
library DecimalsConverter {
    function convert(
        uint256 amount,
        uint256 baseDecimals,
        uint256 destDecimals
    ) internal pure returns (uint256) {
        if (baseDecimals > destDecimals) {
            amount = amount / 10 ** (baseDecimals - destDecimals);
        } else if (baseDecimals < destDecimals) {
            amount = amount * 10 ** (destDecimals - baseDecimals);
        }

        return amount;
    }

    function to18(uint256 amount, uint256 baseDecimals) internal pure returns (uint256) {
        return convert(amount, baseDecimals, 18);
    }

    function to18Safe(
        uint256 amount,
        uint256 baseDecimals
    ) internal pure returns (uint256 resultAmount) {
        return convertSafe(amount, baseDecimals, to18);
    }

    function from18(uint256 amount, uint256 destDecimals) internal pure returns (uint256) {
        return convert(amount, 18, destDecimals);
    }

    function from18Safe(uint256 amount, uint256 destDecimals) internal pure returns (uint256) {
        return convertSafe(amount, destDecimals, from18);
    }

    function round18(uint256 amount, uint256 decimals) internal pure returns (uint256) {
        return to18(from18(amount, decimals), decimals);
    }

    function round18Safe(uint256 amount, uint256 decimals) internal pure returns (uint256) {
        return convertSafe(amount, decimals, round18);
    }

    function convertSafe(
        uint256 amount,
        uint256 decimals,
        function(uint256, uint256) internal pure returns (uint256) convertFunc
    ) internal pure returns (uint256 conversionResult) {
        conversionResult = convertFunc(amount, decimals);

        require(conversionResult > 0, "DecimalsConverter: Incorrect amount after conversion");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../libs/arrays/Paginator.sol";

import "../contracts-registry/AbstractDependant.sol";

import "./ProxyBeacon.sol";

/**
 *  @notice The PoolContractsRegistry module
 *
 *  This contract can be used as a pool registry that keeps track of deployed pools by the system.
 *  One can integrate factories to deploy and register pools or add them manually
 *
 *  The registry uses BeaconProxy pattern to provide upgradeability and Dependant pattern to provide dependency
 *  injection mechanism into the pools. This module should be used together with the ContractsRegistry module.
 *
 *  The users of this module have to override `_onlyPoolFactory()` method and revert in case a wrong msg.sender is
 *  trying to add pools into the registry.
 *
 *  The contract is ment to be used behind a proxy itself.
 */
abstract contract AbstractPoolContractsRegistry is Initializable, AbstractDependant {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Paginator for EnumerableSet.AddressSet;
    using Math for uint256;

    address internal _contractsRegistry;

    mapping(string => ProxyBeacon) private _beacons;
    mapping(string => EnumerableSet.AddressSet) internal _pools; // name => pool

    /**
     *  @notice The proxy initializer function
     */
    function __PoolContractsRegistry_init() internal onlyInitializing {}

    /**
     *  @notice The function that accepts dependencies from the ContractsRegistry, can be overridden
     *  @param contractsRegistry the dependency registry
     */
    function setDependencies(address contractsRegistry) public virtual override dependant {
        _contractsRegistry = contractsRegistry;
    }

    /**
     *  @notice The function to get implementation of the specific pools
     *  @param name the name of the pools
     *  @return address the implementation these pools point to
     */
    function getImplementation(string memory name) public view returns (address) {
        require(
            address(_beacons[name]) != address(0),
            "PoolContractsRegistry: This mapping doesn't exist"
        );

        return _beacons[name].implementation();
    }

    /**
     *  @notice The function to get the BeaconProxy of the specific pools (mostly needed in the factories)
     *  @param name the name of the pools
     *  @return address the BeaconProxy address
     */
    function getProxyBeacon(string memory name) public view returns (address) {
        require(address(_beacons[name]) != address(0), "PoolContractsRegistry: Bad ProxyBeacon");

        return address(_beacons[name]);
    }

    /**
     *  @notice The function to count pools by specified name
     *  @param name the associated pools name
     *  @return the number of pools with this name
     */
    function countPools(string memory name) public view returns (uint256) {
        return _pools[name].length();
    }

    /**
     *  @notice The paginated function to list pools by their name (call `countPools()` to account for pagination)
     *  @param name the associated pools name
     *  @param offset the starting index in the pools array
     *  @param limit the number of pools
     *  @return pools the array of pools proxies
     */
    function listPools(
        string memory name,
        uint256 offset,
        uint256 limit
    ) public view returns (address[] memory pools) {
        return _pools[name].part(offset, limit);
    }

    /**
     *  @notice The function that sets pools' implementations. Deploys ProxyBeacons on the first set.
     *  This function is also used to upgrade pools
     *  @param names the names that are associated with the pools implementations
     *  @param newImplementations the new implementations of the pools (ProxyBeacons will point to these)
     */
    function _setNewImplementations(
        string[] memory names,
        address[] memory newImplementations
    ) internal {
        for (uint256 i = 0; i < names.length; i++) {
            if (address(_beacons[names[i]]) == address(0)) {
                _beacons[names[i]] = new ProxyBeacon();
            }

            if (_beacons[names[i]].implementation() != newImplementations[i]) {
                _beacons[names[i]].upgrade(newImplementations[i]);
            }
        }
    }

    /**
     *  @notice The paginated function that injects new dependencies to the pools. Can be used when the dependant contract
     *  gets fully replaced to update the pools' dependencies
     *  @param name the pools name that will be injected
     *  @param offset the starting index in the pools array
     *  @param limit the number of pools
     */
    function _injectDependenciesToExistingPools(
        string memory name,
        uint256 offset,
        uint256 limit
    ) internal {
        EnumerableSet.AddressSet storage pools = _pools[name];

        uint256 to = (offset + limit).min(pools.length()).max(offset);

        require(to != offset, "PoolContractsRegistry: No pools to inject");

        address contractsRegistry = _contractsRegistry;

        for (uint256 i = offset; i < to; i++) {
            AbstractDependant(pools.at(i)).setDependencies(contractsRegistry);
        }
    }

    /**
     *  @notice The function to add new pools into the registry
     *  @param name the pool's associated name
     *  @param poolAddress the proxy address of the pool
     */
    function _addProxyPool(string memory name, address poolAddress) internal {
        _pools[name].add(poolAddress);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../contracts-registry/AbstractDependant.sol";
import "../AbstractPoolContractsRegistry.sol";

import "./PublicBeaconProxy.sol";

/**
 *  @notice The PoolContractsRegistry module
 *
 *  This is an abstract factory contract that is used in pair with the PoolContractsRegistry contract to
 *  deploy, register and inject pools.
 *
 *  The actual `deploy()` function has to be implemented in the descendants of this contract. The deployment
 *  is made via the BeaconProxy pattern.
 */
abstract contract AbstractPoolFactory is AbstractDependant {
    address internal _contractsRegistry;

    /**
     *  @notice The function that accepts dependencies from the ContractsRegistry, can be overridden
     *  @param contractsRegistry the dependency registry
     */
    function setDependencies(address contractsRegistry) public virtual override dependant {
        _contractsRegistry = contractsRegistry;
    }

    /**
     *  @notice The internal deploy function that deploys BeaconProxy pointing to the
     *  pool implementation taken from the PoolContractRegistry
     */
    function _deploy(address poolRegistry, string memory poolType) internal returns (address) {
        return
            address(
                new PublicBeaconProxy(
                    AbstractPoolContractsRegistry(poolRegistry).getProxyBeacon(poolType),
                    ""
                )
            );
    }

    /**
     *  @notice The internal function that registers newly deployed pool in the provided PoolContractRegistry
     */
    function _register(address poolRegistry, string memory poolType, address poolProxy) internal {
        (bool success, ) = poolRegistry.call(
            abi.encodeWithSignature("addProxyPool(string,address)", poolType, poolProxy)
        );

        require(success, "AbstractPoolFactory: failed to register contract");
    }

    /**
     *  @notice The function that injects dependencies to the newly deployed pool and sets
     *  provided PoolContractsRegistry as an injector
     */
    function _injectDependencies(address poolRegistry, address proxy) internal {
        AbstractDependant(proxy).setDependencies(_contractsRegistry);
        AbstractDependant(proxy).setInjector(poolRegistry);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../AbstractPoolContractsRegistry.sol";

/**
 *  @notice The Ownable preset of PoolContractsRegistry
 */
abstract contract OwnablePoolContractsRegistry is
    AbstractPoolContractsRegistry,
    OwnableUpgradeable
{
    function __OwnablePoolContractsRegistry_init() public initializer {
        __Ownable_init();
        __PoolContractsRegistry_init();
    }

    function setNewImplementations(
        string[] calldata names,
        address[] calldata newImplementations
    ) external onlyOwner {
        _setNewImplementations(names, newImplementations);
    }

    function injectDependenciesToExistingPools(
        string calldata name,
        uint256 offset,
        uint256 limit
    ) external onlyOwner {
        _injectDependenciesToExistingPools(name, offset, limit);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 *  @notice The PoolContractsRegistry module
 *
 *  This is a utility lightweighted ProxyBeacon contract this is used as a beacon that BeaconProxies point to.
 */
contract ProxyBeacon is IBeacon {
    using Address for address;

    address private immutable _owner;
    address private _implementation;

    event Upgraded(address indexed implementation);

    modifier onlyOwner() {
        require(_owner == msg.sender, "ProxyBeacon: Not an owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }

    function implementation() external view override returns (address) {
        return _implementation;
    }

    function upgrade(address newImplementation) external onlyOwner {
        require(newImplementation.isContract(), "ProxyBeacon: Not a contract");

        _implementation = newImplementation;

        emit Upgraded(newImplementation);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155Upgradeable.sol";
import "./IERC1155ReceiverUpgradeable.sol";
import "./extensions/IERC1155MetadataURIUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../utils/introspection/ERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC1155Upgradeable, IERC1155MetadataURIUpgradeable {
    using AddressUpgradeable for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    function __ERC1155_init(string memory uri_) internal onlyInitializing {
        __ERC1155_init_unchained(uri_);
    }

    function __ERC1155_init_unchained(string memory uri_) internal onlyInitializing {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC1155Upgradeable).interfaceId ||
            interfaceId == type(IERC1155MetadataURIUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155ReceiverUpgradeable(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155ReceiverUpgradeable.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[47] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/ERC1155Supply.sol)

pragma solidity ^0.8.0;

import "../ERC1155Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Extension of ERC1155 that adds tracking of total supply per id.
 *
 * Useful for scenarios where Fungible and Non-fungible tokens have to be
 * clearly identified. Note: While a totalSupply of 1 might mean the
 * corresponding is an NFT, there is no guarantees that no other token with the
 * same id are not going to be minted.
 */
abstract contract ERC1155SupplyUpgradeable is Initializable, ERC1155Upgradeable {
    function __ERC1155Supply_init() internal onlyInitializing {
    }

    function __ERC1155Supply_init_unchained() internal onlyInitializing {
    }
    mapping(uint256 => uint256) private _totalSupply;

    /**
     * @dev Total amount of tokens in with a given id.
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    /**
     * @dev Indicates whether any token exist with a given id, or not.
     */
    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155SupplyUpgradeable.totalSupply(id) > 0;
    }

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] -= amounts[i];
            }
        }
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155Upgradeable.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURIUpgradeable is IERC1155Upgradeable {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {
    function __ERC1155Holder_init() internal onlyInitializing {
    }

    function __ERC1155Holder_init_unchained() internal onlyInitializing {
    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155ReceiverUpgradeable.sol";
import "../../../utils/introspection/ERC165Upgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal onlyInitializing {
    }

    function __ERC1155Receiver_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

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
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
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
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721ReceiverUpgradeable.sol";
import "../../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal onlyInitializing {
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSAUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712Upgradeable is Initializable {
    /* solhint-disable var-name-mixedcase */
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }

    /**
     * @dev The hash of the name parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    /**
     * @dev The hash of the version parameter for the EIP712 domain.
     *
     * NOTE: This function reads from storage by default, but can be redefined to return a constant value if gas costs
     * are a concern.
     */
    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../StringsUpgradeable.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165Upgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    /**
     * This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library StringsUpgradeable {
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
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/BeaconProxy.sol)

pragma solidity ^0.8.0;

import "./IBeacon.sol";
import "../Proxy.sol";
import "../ERC1967/ERC1967Upgrade.sol";

/**
 * @dev This contract implements a proxy that gets the implementation address for each call from a {UpgradeableBeacon}.
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
     * will typically be an encoded function call, and allows initializating the storage of the proxy like a Solidity
     * constructor.
     *
     * Requirements:
     *
     * - `beacon` must be a contract with the interface {IBeacon}.
     */
    constructor(address beacon, bytes memory data) payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
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
// OpenZeppelin Contracts v4.4.1 (proxy/ERC1967/ERC1967Proxy.sol)

pragma solidity ^0.8.0;

import "../Proxy.sol";
import "./ERC1967Upgrade.sol";

/**
 * @dev This contract implements an upgradeable proxy. It is upgradeable because calls are delegated to an
 * implementation address that can be changed. This address is stored in storage in the location specified by
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967], so that it doesn't conflict with the storage layout of the
 * implementation behind the proxy.
 */
contract ERC1967Proxy is Proxy, ERC1967Upgrade {
    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializating the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
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
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/Proxy.sol)

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
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
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
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/transparent/TransparentUpgradeableProxy.sol)

pragma solidity ^0.8.0;

import "../ERC1967/ERC1967Proxy.sol";

/**
 * @dev This contract implements a proxy that is upgradeable by an admin.
 *
 * To avoid https://medium.com/nomic-labs-blog/malicious-backdoors-in-ethereum-proxies-62629adf3357[proxy selector
 * clashing], which can potentially be used in an attack, this contract uses the
 * https://blog.openzeppelin.com/the-transparent-proxy-pattern/[transparent proxy pattern]. This pattern implies two
 * things that go hand in hand:
 *
 * 1. If any account other than the admin calls the proxy, the call will be forwarded to the implementation, even if
 * that call matches one of the admin functions exposed by the proxy itself.
 * 2. If the admin calls the proxy, it can access the admin functions, but its calls will never be forwarded to the
 * implementation. If the admin tries to call a function on the implementation it will fail with an error that says
 * "admin cannot fallback to proxy target".
 *
 * These properties mean that the admin account can only be used for admin actions like upgrading the proxy or changing
 * the admin, so it's best if it's a dedicated account that is not used for anything else. This will avoid headaches due
 * to sudden errors when trying to call a function from the proxy implementation.
 *
 * Our recommendation is for the dedicated account to be an instance of the {ProxyAdmin} contract. If set up this way,
 * you should think of the `ProxyAdmin` instance as the real administrative interface of your proxy.
 */
contract TransparentUpgradeableProxy is ERC1967Proxy {
    /**
     * @dev Initializes an upgradeable proxy managed by `_admin`, backed by the implementation at `_logic`, and
     * optionally initialized with `_data` as explained in {ERC1967Proxy-constructor}.
     */
    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _changeAdmin(admin_);
    }

    /**
     * @dev Modifier used internally that will delegate the call to the implementation unless the sender is the admin.
     */
    modifier ifAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    /**
     * @dev Returns the current admin.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyAdmin}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
     */
    function admin() external ifAdmin returns (address admin_) {
        admin_ = _getAdmin();
    }

    /**
     * @dev Returns the current implementation.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-getProxyImplementation}.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by EIP1967) using the
     * https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function implementation() external ifAdmin returns (address implementation_) {
        implementation_ = _implementation();
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-changeProxyAdmin}.
     */
    function changeAdmin(address newAdmin) external virtual ifAdmin {
        _changeAdmin(newAdmin);
    }

    /**
     * @dev Upgrade the implementation of the proxy.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgrade}.
     */
    function upgradeTo(address newImplementation) external ifAdmin {
        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy, and then call a function from the new implementation as specified
     * by `data`, which should be an encoded function call. This is useful to initialize new storage variables in the
     * proxied contract.
     *
     * NOTE: Only the admin can call this function. See {ProxyAdmin-upgradeAndCall}.
     */
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {
        _upgradeToAndCall(newImplementation, data, true);
    }

    /**
     * @dev Returns the current admin.
     */
    function _admin() internal view virtual returns (address) {
        return _getAdmin();
    }

    /**
     * @dev Makes sure the admin cannot access the fallback function. See {Proxy-_beforeFallback}.
     */
    function _beforeFallback() internal virtual override {
        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Snapshot.sol)

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Arrays.sol";
import "../../../utils/Counters.sol";

/**
 * @dev This contract extends an ERC20 token with a snapshot mechanism. When a snapshot is created, the balances and
 * total supply at the time are recorded for later access.
 *
 * This can be used to safely create mechanisms based on token balances such as trustless dividends or weighted voting.
 * In naive implementations it's possible to perform a "double spend" attack by reusing the same balance from different
 * accounts. By using snapshots to calculate dividends or voting power, those attacks no longer apply. It can also be
 * used to create an efficient ERC20 forking mechanism.
 *
 * Snapshots are created by the internal {_snapshot} function, which will emit the {Snapshot} event and return a
 * snapshot id. To get the total supply at the time of a snapshot, call the function {totalSupplyAt} with the snapshot
 * id. To get the balance of an account at the time of a snapshot, call the {balanceOfAt} function with the snapshot id
 * and the account address.
 *
 * NOTE: Snapshot policy can be customized by overriding the {_getCurrentSnapshotId} method. For example, having it
 * return `block.number` will trigger the creation of snapshot at the begining of each new block. When overridding this
 * function, be careful about the monotonicity of its result. Non-monotonic snapshot ids will break the contract.
 *
 * Implementing snapshots for every block using this method will incur significant gas costs. For a gas-efficient
 * alternative consider {ERC20Votes}.
 *
 * ==== Gas Costs
 *
 * Snapshots are efficient. Snapshot creation is _O(1)_. Retrieval of balances or total supply from a snapshot is _O(log
 * n)_ in the number of snapshots that have been created, although _n_ for a specific account will generally be much
 * smaller since identical balances in subsequent snapshots are stored as a single entry.
 *
 * There is a constant overhead for normal ERC20 transfers due to the additional snapshot bookkeeping. This overhead is
 * only significant for the first transfer that immediately follows a snapshot for a particular account. Subsequent
 * transfers will have normal cost until the next snapshot, and so on.
 */

abstract contract ERC20Snapshot is ERC20 {
    // Inspired by Jordi Baylina's MiniMeToken to record historical balances:
    // https://github.com/Giveth/minimd/blob/ea04d950eea153a04c51fa510b068b9dded390cb/contracts/MiniMeToken.sol

    using Arrays for uint256[];
    using Counters for Counters.Counter;

    // Snapshotted values have arrays of ids and the value corresponding to that id. These could be an array of a
    // Snapshot struct, but that would impede usage of functions that work on an array.
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    // Snapshot ids increase monotonically, with the first value being 1. An id of 0 is invalid.
    Counters.Counter private _currentSnapshotId;

    /**
     * @dev Emitted by {_snapshot} when a snapshot identified by `id` is created.
     */
    event Snapshot(uint256 id);

    /**
     * @dev Creates a new snapshot and returns its snapshot id.
     *
     * Emits a {Snapshot} event that contains the same id.
     *
     * {_snapshot} is `internal` and you have to decide how to expose it externally. Its usage may be restricted to a
     * set of accounts, for example using {AccessControl}, or it may be open to the public.
     *
     * [WARNING]
     * ====
     * While an open way of calling {_snapshot} is required for certain trust minimization mechanisms such as forking,
     * you must consider that it can potentially be used by attackers in two ways.
     *
     * First, it can be used to increase the cost of retrieval of values from snapshots, although it will grow
     * logarithmically thus rendering this attack ineffective in the long term. Second, it can be used to target
     * specific accounts and increase the cost of ERC20 transfers for them, in the ways specified in the Gas Costs
     * section above.
     *
     * We haven't measured the actual numbers; if this is something you're interested in please reach out to us.
     * ====
     */
    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }

    /**
     * @dev Get the current snapshotId
     */
    function _getCurrentSnapshotId() internal view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }

    /**
     * @dev Retrieves the balance of `account` at the time `snapshotId` was created.
     */
    function balanceOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    /**
     * @dev Retrieves the total supply at the time `snapshotId` was created.
     */
    function totalSupplyAt(uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    // Update balance and/or total supply snapshots before the values are modified. This is implemented
    // in the _beforeTokenTransfer hook, which is executed for _mint, _burn, and _transfer operations.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            // mint
            _updateAccountSnapshot(to);
            _updateTotalSupplySnapshot();
        } else if (to == address(0)) {
            // burn
            _updateAccountSnapshot(from);
            _updateTotalSupplySnapshot();
        } else {
            // transfer
            _updateAccountSnapshot(from);
            _updateAccountSnapshot(to);
        }
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots) private view returns (bool, uint256) {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _getCurrentSnapshotId(), "ERC20Snapshot: nonexistent id");

        // When a valid snapshot is queried, there are three possibilities:
        //  a) The queried value was not modified after the snapshot was taken. Therefore, a snapshot entry was never
        //  created for this id, and all stored snapshot ids are smaller than the requested one. The value that corresponds
        //  to this id is the current one.
        //  b) The queried value was modified after the snapshot was taken. Therefore, there will be an entry with the
        //  requested id, and its value is the one to return.
        //  c) More snapshots were created after the requested one, and the queried value was later modified. There will be
        //  no entry for the requested id: the value that corresponds to it is that of the smallest snapshot id that is
        //  larger than the requested one.
        //
        // In summary, we need to find an element in an array, returning the index of the smallest value that is larger if
        // it is not found, unless said value doesn't exist (e.g. when all values are smaller). Arrays.findUpperBound does
        // exactly this.

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits a {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

import "../ERC721.sol";

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
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
// OpenZeppelin Contracts v4.4.1 (utils/Arrays.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
    /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
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
// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

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
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
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
// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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

        assembly {
            result := store
        }

        return result;
    }
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
pragma solidity ^0.8.4;

import "@dlsl/dev-modules/contracts-registry/presets/OwnableContractsRegistry.sol";

import "../interfaces/core/IContractsRegistry.sol";

contract ContractsRegistry is IContractsRegistry, OwnableContractsRegistry {
    string public constant USER_REGISTRY_NAME = "USER_REGISTRY";

    string public constant POOL_FACTORY_NAME = "POOL_FACTORY";
    string public constant POOL_REGISTRY_NAME = "POOL_REGISTRY";

    string public constant DEXE_NAME = "DEXE";
    string public constant USD_NAME = "USD";

    string public constant PRICE_FEED_NAME = "PRICE_FEED";
    string public constant UNISWAP_V2_ROUTER_NAME = "UNISWAP_V2_ROUTER";
    string public constant UNISWAP_V2_FACTORY_NAME = "UNISWAP_V2_FACTORY";

    string public constant INSURANCE_NAME = "INSURANCE";
    string public constant TREASURY_NAME = "TREASURY";
    string public constant DIVIDENDS_NAME = "DIVIDENDS";

    string public constant CORE_PROPERTIES_NAME = "CORE_PROPERTIES";

    function getUserRegistryContract() external view override returns (address) {
        return getContract(USER_REGISTRY_NAME);
    }

    function getPoolFactoryContract() external view override returns (address) {
        return getContract(POOL_FACTORY_NAME);
    }

    function getPoolRegistryContract() external view override returns (address) {
        return getContract(POOL_REGISTRY_NAME);
    }

    function getDEXEContract() external view override returns (address) {
        return getContract(DEXE_NAME);
    }

    function getUSDContract() external view override returns (address) {
        return getContract(USD_NAME);
    }

    function getPriceFeedContract() external view override returns (address) {
        return getContract(PRICE_FEED_NAME);
    }

    function getUniswapV2RouterContract() external view override returns (address) {
        return getContract(UNISWAP_V2_ROUTER_NAME);
    }

    function getUniswapV2FactoryContract() external view override returns (address) {
        return getContract(UNISWAP_V2_FACTORY_NAME);
    }

    function getInsuranceContract() external view override returns (address) {
        return getContract(INSURANCE_NAME);
    }

    function getTreasuryContract() external view override returns (address) {
        return getContract(TREASURY_NAME);
    }

    function getDividendsContract() external view override returns (address) {
        return getContract(DIVIDENDS_NAME);
    }

    function getCorePropertiesContract() external view override returns (address) {
        return getContract(CORE_PROPERTIES_NAME);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";
import "@dlsl/dev-modules/libs/arrays/Paginator.sol";

import "../interfaces/core/ICoreProperties.sol";
import "../interfaces/core/IContractsRegistry.sol";

import "../libs/utils/AddressSetHelper.sol";

import "./Globals.sol";

contract CoreProperties is ICoreProperties, OwnableUpgradeable, AbstractDependant {
    using EnumerableSet for EnumerableSet.AddressSet;
    using AddressSetHelper for EnumerableSet.AddressSet;
    using Paginator for EnumerableSet.AddressSet;
    using Math for uint256;

    CoreParameters public coreParameters;

    address internal _insuranceAddress;
    address internal _treasuryAddress;
    address internal _dividendsAddress;

    EnumerableSet.AddressSet internal _whitelistTokens;
    EnumerableSet.AddressSet internal _blacklistTokens;

    function __CoreProperties_init(CoreParameters calldata _coreParameters) external initializer {
        __Ownable_init();

        coreParameters = _coreParameters;
    }

    function setDependencies(address contractsRegistry) public virtual override dependant {
        IContractsRegistry registry = IContractsRegistry(contractsRegistry);

        _insuranceAddress = registry.getInsuranceContract();
        _treasuryAddress = registry.getTreasuryContract();
        _dividendsAddress = registry.getDividendsContract();
    }

    function setCoreParameters(
        CoreParameters calldata _coreParameters
    ) external override onlyOwner {
        coreParameters = _coreParameters;
    }

    function addWhitelistTokens(address[] calldata tokens) external override onlyOwner {
        _whitelistTokens.add(tokens);
    }

    function removeWhitelistTokens(address[] calldata tokens) external override onlyOwner {
        _whitelistTokens.remove(tokens);
    }

    function addBlacklistTokens(address[] calldata tokens) external override onlyOwner {
        _blacklistTokens.add(tokens);
    }

    function removeBlacklistTokens(address[] calldata tokens) external override onlyOwner {
        _blacklistTokens.remove(tokens);
    }

    function setMaximumPoolInvestors(uint256 count) external override onlyOwner {
        coreParameters.traderParams.maxPoolInvestors = count;
    }

    function setMaximumOpenPositions(uint256 count) external override onlyOwner {
        coreParameters.traderParams.maxOpenPositions = count;
    }

    function setTraderLeverageParams(
        uint256 threshold,
        uint256 slope
    ) external override onlyOwner {
        coreParameters.traderParams.leverageThreshold = threshold;
        coreParameters.traderParams.leverageSlope = slope;
    }

    function setCommissionInitTimestamp(uint256 timestamp) external override onlyOwner {
        coreParameters.traderParams.commissionInitTimestamp = timestamp;
    }

    function setCommissionDurations(uint256[] calldata durations) external override onlyOwner {
        coreParameters.traderParams.commissionDurations = durations;
    }

    function setDEXECommissionPercentages(
        uint256 dexeCommission,
        uint256 govCommission,
        uint256[] calldata distributionPercentages
    ) external override onlyOwner {
        coreParameters.traderParams.dexeCommissionPercentage = dexeCommission;
        coreParameters
            .traderParams
            .dexeCommissionDistributionPercentages = distributionPercentages;
        coreParameters.govParams.govCommissionPercentage = govCommission;
    }

    function setTraderCommissionPercentages(
        uint256 minTraderCommission,
        uint256[] calldata maxTraderCommissions
    ) external override onlyOwner {
        coreParameters.traderParams.minTraderCommission = minTraderCommission;
        coreParameters.traderParams.maxTraderCommissions = maxTraderCommissions;
    }

    function setDelayForRiskyPool(uint256 delayForRiskyPool) external override onlyOwner {
        coreParameters.traderParams.delayForRiskyPool = delayForRiskyPool;
    }

    function setInsuranceParameters(
        InsuranceParameters calldata insuranceParams
    ) external override onlyOwner {
        coreParameters.insuranceParams = insuranceParams;
    }

    function setGovVotesLimit(uint256 newVotesLimit) external override onlyOwner {
        coreParameters.govParams.govVotesLimit = newVotesLimit;
    }

    function totalWhitelistTokens() external view override returns (uint256) {
        return _whitelistTokens.length();
    }

    function totalBlacklistTokens() external view override returns (uint256) {
        return _blacklistTokens.length();
    }

    function getWhitelistTokens(
        uint256 offset,
        uint256 limit
    ) external view override returns (address[] memory tokens) {
        return _whitelistTokens.part(offset, limit);
    }

    function getBlacklistTokens(
        uint256 offset,
        uint256 limit
    ) external view override returns (address[] memory tokens) {
        return _blacklistTokens.part(offset, limit);
    }

    function isWhitelistedToken(address token) external view override returns (bool) {
        return _whitelistTokens.contains(token);
    }

    function isBlacklistedToken(address token) external view override returns (bool) {
        return _blacklistTokens.contains(token);
    }

    function getFilteredPositions(
        address[] memory positions
    ) external view override returns (address[] memory filteredPositions) {
        uint256 newLength = positions.length;

        for (uint256 i = positions.length; i > 0; i--) {
            if (_blacklistTokens.contains(positions[i - 1])) {
                if (i == newLength) {
                    --newLength;
                } else {
                    positions[i - 1] = positions[--newLength];
                }
            }
        }

        filteredPositions = new address[](newLength);

        for (uint256 i = 0; i < newLength; i++) {
            filteredPositions[i] = positions[i];
        }
    }

    function getMaximumPoolInvestors() external view override returns (uint256) {
        return coreParameters.traderParams.maxPoolInvestors;
    }

    function getMaximumOpenPositions() external view override returns (uint256) {
        return coreParameters.traderParams.maxOpenPositions;
    }

    function getTraderLeverageParams() external view override returns (uint256, uint256) {
        return (
            coreParameters.traderParams.leverageThreshold,
            coreParameters.traderParams.leverageSlope
        );
    }

    function getCommissionInitTimestamp() public view override returns (uint256) {
        return coreParameters.traderParams.commissionInitTimestamp;
    }

    function getCommissionDuration(
        CommissionPeriod period
    ) public view override returns (uint256) {
        return coreParameters.traderParams.commissionDurations[uint256(period)];
    }

    function getDEXECommissionPercentages()
        external
        view
        override
        returns (uint256, uint256, uint256[] memory, address[3] memory)
    {
        return (
            coreParameters.traderParams.dexeCommissionPercentage,
            coreParameters.govParams.govCommissionPercentage,
            coreParameters.traderParams.dexeCommissionDistributionPercentages,
            [_insuranceAddress, _treasuryAddress, _dividendsAddress]
        );
    }

    function getTraderCommissions() external view override returns (uint256, uint256[] memory) {
        return (
            coreParameters.traderParams.minTraderCommission,
            coreParameters.traderParams.maxTraderCommissions
        );
    }

    function getDelayForRiskyPool() external view override returns (uint256) {
        return coreParameters.traderParams.delayForRiskyPool;
    }

    function getInsuranceFactor() external view override returns (uint256) {
        return coreParameters.insuranceParams.insuranceFactor;
    }

    function getMaxInsurancePoolShare() external view override returns (uint256) {
        return coreParameters.insuranceParams.maxInsurancePoolShare;
    }

    function getMinInsuranceDeposit() external view override returns (uint256) {
        return coreParameters.insuranceParams.minInsuranceDeposit;
    }

    function getInsuranceWithdrawalLock() external view override returns (uint256) {
        return coreParameters.insuranceParams.insuranceWithdrawalLock;
    }

    function getGovVotesLimit() external view override returns (uint256) {
        return coreParameters.govParams.govVotesLimit;
    }

    function getCommissionEpochByTimestamp(
        uint256 timestamp,
        CommissionPeriod commissionPeriod
    ) external view override returns (uint256) {
        return
            (timestamp - getCommissionInitTimestamp()) /
            getCommissionDuration(commissionPeriod) +
            1;
    }

    function getCommissionTimestampByEpoch(
        uint256 epoch,
        CommissionPeriod commissionPeriod
    ) external view override returns (uint256) {
        return getCommissionInitTimestamp() + epoch * getCommissionDuration(commissionPeriod) - 1;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

uint256 constant YEAR = 1 days * 365;

uint256 constant PERCENTAGE_100 = 10 ** 27;
uint256 constant PRECISION = 10 ** 25;
uint256 constant DECIMALS = 10 ** 18;

uint256 constant MAX_UINT = type(uint256).max;

address constant ETHEREUM_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";
import "@dlsl/dev-modules/libs/arrays/ArrayHelper.sol";
import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

import "../interfaces/core/IPriceFeed.sol";
import "../interfaces/core/IContractsRegistry.sol";

import "../libs/price-feed/UniswapV2PathFinder.sol";
import "../libs/utils/AddressSetHelper.sol";

import "../core/Globals.sol";

contract PriceFeed is IPriceFeed, OwnableUpgradeable, AbstractDependant {
    using EnumerableSet for EnumerableSet.AddressSet;
    using AddressSetHelper for EnumerableSet.AddressSet;
    using DecimalsConverter for uint256;
    using SafeERC20 for IERC20;
    using ArrayHelper for address[];
    using UniswapV2PathFinder for EnumerableSet.AddressSet;

    IUniswapV2Factory public uniswapFactory;
    IUniswapV2Router02 public uniswapV2Router;
    address internal _usdAddress;
    address internal _dexeAddress;

    EnumerableSet.AddressSet internal _pathTokens;

    mapping(address => mapping(address => mapping(address => address[]))) internal _savedPaths; // pool => token from => token to => path

    function __PriceFeed_init() external initializer {
        __Ownable_init();
    }

    function setDependencies(address contractsRegistry) public virtual override dependant {
        IContractsRegistry registry = IContractsRegistry(contractsRegistry);

        uniswapFactory = IUniswapV2Factory(registry.getUniswapV2FactoryContract());
        uniswapV2Router = IUniswapV2Router02(registry.getUniswapV2RouterContract());
        _usdAddress = registry.getUSDContract();
        _dexeAddress = registry.getDEXEContract();
    }

    /// @notice this function sets path tokens that are used throughout the platform to calculate prices
    function addPathTokens(address[] calldata pathTokens) external override onlyOwner {
        _pathTokens.add(pathTokens);
    }

    function removePathTokens(address[] calldata pathTokens) external override onlyOwner {
        _pathTokens.remove(pathTokens);
    }

    function exchangeFromExact(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] memory optionalPath,
        uint256 minAmountOut
    ) public virtual override returns (uint256) {
        if (amountIn == 0) {
            return 0;
        }

        if (inToken == outToken) {
            return amountIn;
        }

        if (optionalPath.length == 0) {
            optionalPath = _savedPaths[msg.sender][inToken][outToken];
        }

        FoundPath memory foundPath = _pathTokens.getUniV2PathWithPriceOut(
            inToken,
            outToken,
            amountIn,
            optionalPath
        );

        require(foundPath.path.length > 0, "PriceFeed: unreachable asset");

        if (foundPath.withProvidedPath) {
            _savePath(inToken, outToken, foundPath.path);
        }

        _grabTokens(inToken, amountIn);

        uint256[] memory outs = uniswapV2Router.swapExactTokensForTokens(
            amountIn,
            minAmountOut,
            foundPath.path,
            msg.sender,
            block.timestamp
        );

        return outs[outs.length - 1];
    }

    function exchangeToExact(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] memory optionalPath,
        uint256 maxAmountIn
    ) public virtual override returns (uint256) {
        if (amountOut == 0) {
            return 0;
        }

        if (inToken == outToken) {
            return amountOut;
        }

        if (optionalPath.length == 0) {
            optionalPath = _savedPaths[msg.sender][inToken][outToken];
        }

        FoundPath memory foundPath = _pathTokens.getUniV2PathWithPriceIn(
            inToken,
            outToken,
            amountOut,
            optionalPath
        );

        require(foundPath.path.length > 0, "PriceFeed: unreachable asset");

        if (foundPath.withProvidedPath) {
            _savePath(inToken, outToken, foundPath.path);
        }

        _grabTokens(inToken, maxAmountIn);

        uint256[] memory ins = uniswapV2Router.swapTokensForExactTokens(
            amountOut,
            maxAmountIn,
            foundPath.path,
            msg.sender,
            block.timestamp
        );

        IERC20(inToken).safeTransfer(msg.sender, maxAmountIn - ins[0]);

        return ins[0];
    }

    function normalizedExchangeFromExact(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] calldata optionalPath,
        uint256 minAmountOut
    ) external virtual override returns (uint256) {
        uint256 outDecimals = ERC20(outToken).decimals();

        return
            exchangeFromExact(
                inToken,
                outToken,
                amountIn.from18(ERC20(inToken).decimals()),
                optionalPath,
                minAmountOut.from18(outDecimals)
            ).to18(outDecimals);
    }

    function normalizedExchangeToExact(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] calldata optionalPath,
        uint256 maxAmountIn
    ) external virtual override returns (uint256) {
        uint256 inDecimals = ERC20(inToken).decimals();

        return
            exchangeToExact(
                inToken,
                outToken,
                amountOut.from18(ERC20(outToken).decimals()),
                optionalPath,
                maxAmountIn.from18(inDecimals)
            ).to18(inDecimals);
    }

    function getExtendedPriceOut(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] memory optionalPath
    ) public view virtual override returns (uint256 amountOut, address[] memory path) {
        if (inToken == outToken) {
            return (amountIn, new address[](0));
        }

        if (optionalPath.length == 0) {
            optionalPath = _savedPaths[msg.sender][inToken][outToken];
        }

        FoundPath memory foundPath = _pathTokens.getUniV2PathWithPriceOut(
            inToken,
            outToken,
            amountIn,
            optionalPath
        );

        return
            foundPath.amounts.length > 0
                ? (foundPath.amounts[foundPath.amounts.length - 1], foundPath.path)
                : (0, new address[](0));
    }

    function getExtendedPriceIn(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] memory optionalPath
    ) public view virtual override returns (uint256 amountIn, address[] memory path) {
        if (inToken == outToken) {
            return (amountOut, new address[](0));
        }

        if (optionalPath.length == 0) {
            optionalPath = _savedPaths[msg.sender][inToken][outToken];
        }

        FoundPath memory foundPath = _pathTokens.getUniV2PathWithPriceIn(
            inToken,
            outToken,
            amountOut,
            optionalPath
        );

        return
            foundPath.amounts.length > 0
                ? (foundPath.amounts[0], foundPath.path)
                : (0, new address[](0));
    }

    function getNormalizedExtendedPriceOut(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] memory optionalPath
    ) public view virtual override returns (uint256 amountOut, address[] memory path) {
        (amountOut, path) = getExtendedPriceOut(
            inToken,
            outToken,
            amountIn.from18(ERC20(inToken).decimals()),
            optionalPath
        );

        amountOut = amountOut.to18(ERC20(outToken).decimals());
    }

    function getNormalizedExtendedPriceIn(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] memory optionalPath
    ) public view virtual override returns (uint256 amountIn, address[] memory path) {
        (amountIn, path) = getExtendedPriceIn(
            inToken,
            outToken,
            amountOut.from18(ERC20(outToken).decimals()),
            optionalPath
        );

        amountIn = amountIn.to18(ERC20(inToken).decimals());
    }

    function getNormalizedPriceOut(
        address inToken,
        address outToken,
        uint256 amountIn
    ) public view virtual override returns (uint256 amountOut, address[] memory path) {
        return
            getNormalizedExtendedPriceOut(
                inToken,
                outToken,
                amountIn,
                _savedPaths[msg.sender][inToken][outToken]
            );
    }

    function getNormalizedPriceIn(
        address inToken,
        address outToken,
        uint256 amountOut
    ) public view virtual override returns (uint256 amountIn, address[] memory path) {
        return
            getNormalizedExtendedPriceIn(
                inToken,
                outToken,
                amountOut,
                _savedPaths[msg.sender][inToken][outToken]
            );
    }

    function getNormalizedPriceOutUSD(
        address inToken,
        uint256 amountIn
    ) external view override returns (uint256 amountOut, address[] memory path) {
        return getNormalizedPriceOut(inToken, _usdAddress, amountIn);
    }

    function getNormalizedPriceInUSD(
        address inToken,
        uint256 amountOut
    ) external view override returns (uint256 amountIn, address[] memory path) {
        return getNormalizedPriceIn(inToken, _usdAddress, amountOut);
    }

    function getNormalizedPriceOutDEXE(
        address inToken,
        uint256 amountIn
    ) external view override returns (uint256 amountOut, address[] memory path) {
        return getNormalizedPriceOut(inToken, _dexeAddress, amountIn);
    }

    function getNormalizedPriceInDEXE(
        address inToken,
        uint256 amountOut
    ) external view override returns (uint256 amountIn, address[] memory path) {
        return getNormalizedPriceIn(inToken, _dexeAddress, amountOut);
    }

    function totalPathTokens() external view override returns (uint256) {
        return _pathTokens.length();
    }

    function getPathTokens() external view override returns (address[] memory) {
        return _pathTokens.values();
    }

    function getSavedPaths(
        address pool,
        address from,
        address to
    ) external view override returns (address[] memory) {
        return _savedPaths[pool][from][to];
    }

    function isSupportedPathToken(address token) external view override returns (bool) {
        return _pathTokens.contains(token);
    }

    function _savePath(address inToken, address outToken, address[] memory path) internal {
        if (
            keccak256(abi.encode(path)) !=
            keccak256(abi.encode(_savedPaths[msg.sender][inToken][outToken]))
        ) {
            _savedPaths[msg.sender][inToken][outToken] = path;
            _savedPaths[msg.sender][outToken][inToken] = path.reverse();
        }
    }

    function _grabTokens(address token, uint256 amount) internal {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        if (IERC20(token).allowance(address(this), address(uniswapV2Router)) == 0) {
            IERC20(token).safeApprove(address(uniswapV2Router), MAX_UINT);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/factory/IPoolFactory.sol";
import "../interfaces/trader/ITraderPool.sol";
import "../interfaces/core/IContractsRegistry.sol";

import "@dlsl/dev-modules/pool-contracts-registry/pool-factory/AbstractPoolFactory.sol";

import {DistributionProposal} from "../gov/proposals/DistributionProposal.sol";
import "../gov/GovPool.sol";
import "../gov/user-keeper/GovUserKeeper.sol";
import "../gov/settings/GovSettings.sol";
import "../gov/validators/GovValidators.sol";

import "../trader/BasicTraderPool.sol";
import "../trader/InvestTraderPool.sol";
import "../trader/TraderPoolRiskyProposal.sol";
import "../trader/TraderPoolInvestProposal.sol";

import "../core/CoreProperties.sol";
import "./PoolRegistry.sol";

import "../core/Globals.sol";

contract PoolFactory is IPoolFactory, AbstractPoolFactory {
    PoolRegistry internal _poolRegistry;

    CoreProperties internal _coreProperties;

    event TraderPoolDeployed(
        string poolType,
        string symbol,
        string name,
        address at,
        address proposalContract,
        address trader,
        address basicToken,
        uint256 commission,
        string descriptionURL
    );

    event DaoPoolDeployed(
        string name,
        address govPool,
        address DP,
        address validators,
        address settings,
        address govUserKeeper,
        address sender
    );

    function setDependencies(address contractsRegistry) public override {
        super.setDependencies(contractsRegistry);

        IContractsRegistry registry = IContractsRegistry(contractsRegistry);

        _poolRegistry = PoolRegistry(registry.getPoolRegistryContract());
        _coreProperties = CoreProperties(registry.getCorePropertiesContract());
    }

    function deployGovPool(GovPoolDeployParams calldata parameters) external override {
        string memory poolType = _poolRegistry.GOV_POOL_NAME();

        address validatorsProxy = _deploy(_poolRegistry.VALIDATORS_NAME());

        GovValidators(validatorsProxy).__GovValidators_init(
            parameters.validatorsParams.name,
            parameters.validatorsParams.symbol,
            parameters.validatorsParams.duration,
            parameters.validatorsParams.quorum,
            parameters.validatorsParams.validators,
            parameters.validatorsParams.balances
        );

        address userKeeperProxy = _deploy(_poolRegistry.USER_KEEPER_NAME());
        address dpProxy = _deploy(_poolRegistry.DISTRIBUTION_PROPOSAL_NAME());
        address settingsProxy = _deploy(_poolRegistry.SETTINGS_NAME());
        address poolProxy = _deploy(poolType);

        emit DaoPoolDeployed(
            parameters.name,
            poolProxy,
            dpProxy,
            validatorsProxy,
            settingsProxy,
            userKeeperProxy,
            msg.sender
        );

        GovUserKeeper(userKeeperProxy).__GovUserKeeper_init(
            parameters.userKeeperParams.tokenAddress,
            parameters.userKeeperParams.nftAddress,
            parameters.userKeeperParams.totalPowerInTokens,
            parameters.userKeeperParams.nftsTotalSupply
        );

        DistributionProposal(payable(dpProxy)).__DistributionProposal_init(poolProxy);
        GovSettings(settingsProxy).__GovSettings_init(
            address(poolProxy),
            address(dpProxy),
            address(validatorsProxy),
            address(userKeeperProxy),
            parameters.settingsParams.proposalSettings,
            parameters.settingsParams.additionalProposalExecutors
        );
        GovPool(payable(poolProxy)).__GovPool_init(
            settingsProxy,
            userKeeperProxy,
            dpProxy,
            validatorsProxy,
            parameters.nftMultiplierAddress,
            parameters.descriptionURL,
            parameters.name
        );

        GovSettings(settingsProxy).transferOwnership(poolProxy);
        GovUserKeeper(userKeeperProxy).transferOwnership(poolProxy);
        GovValidators(validatorsProxy).transferOwnership(poolProxy);

        _register(poolType, poolProxy);
        _injectDependencies(poolProxy);
    }

    function deployBasicPool(
        string calldata name,
        string calldata symbol,
        TraderPoolDeployParameters calldata parameters
    ) external override {
        string memory poolType = _poolRegistry.BASIC_POOL_NAME();
        ITraderPool.PoolParameters
            memory poolParameters = _validateAndConstructTraderPoolParameters(parameters);

        address proposalProxy = _deploy(_poolRegistry.RISKY_PROPOSAL_NAME());
        address poolProxy = _deploy(poolType);

        BasicTraderPool(poolProxy).__BasicTraderPool_init(
            name,
            symbol,
            poolParameters,
            proposalProxy
        );
        TraderPoolRiskyProposal(proposalProxy).__TraderPoolRiskyProposal_init(
            ITraderPoolProposal.ParentTraderPoolInfo(
                poolProxy,
                poolParameters.trader,
                poolParameters.baseToken,
                poolParameters.baseTokenDecimals
            )
        );

        _register(poolType, poolProxy);
        _injectDependencies(poolProxy);

        _poolRegistry.associateUserWithPool(poolParameters.trader, poolType, poolProxy);

        emit TraderPoolDeployed(
            poolType,
            symbol,
            name,
            poolProxy,
            proposalProxy,
            poolParameters.trader,
            poolParameters.baseToken,
            poolParameters.commissionPercentage,
            poolParameters.descriptionURL
        );
    }

    function deployInvestPool(
        string calldata name,
        string calldata symbol,
        TraderPoolDeployParameters calldata parameters
    ) external override {
        string memory poolType = _poolRegistry.INVEST_POOL_NAME();
        ITraderPool.PoolParameters
            memory poolParameters = _validateAndConstructTraderPoolParameters(parameters);

        address proposalProxy = _deploy(_poolRegistry.INVEST_PROPOSAL_NAME());
        address poolProxy = _deploy(poolType);

        InvestTraderPool(poolProxy).__InvestTraderPool_init(
            name,
            symbol,
            poolParameters,
            proposalProxy
        );
        TraderPoolInvestProposal(proposalProxy).__TraderPoolInvestProposal_init(
            ITraderPoolProposal.ParentTraderPoolInfo(
                poolProxy,
                poolParameters.trader,
                poolParameters.baseToken,
                poolParameters.baseTokenDecimals
            )
        );

        _register(poolType, poolProxy);
        _injectDependencies(poolProxy);

        _poolRegistry.associateUserWithPool(poolParameters.trader, poolType, poolProxy);

        emit TraderPoolDeployed(
            poolType,
            symbol,
            name,
            poolProxy,
            proposalProxy,
            poolParameters.trader,
            poolParameters.baseToken,
            poolParameters.commissionPercentage,
            poolParameters.descriptionURL
        );
    }

    function _deploy(string memory poolType) internal returns (address) {
        return _deploy(address(_poolRegistry), poolType);
    }

    function _register(string memory poolType, address poolProxy) internal {
        _register(address(_poolRegistry), poolType, poolProxy);
    }

    function _injectDependencies(address proxy) internal {
        _injectDependencies(address(_poolRegistry), proxy);
    }

    function _validateAndConstructTraderPoolParameters(
        TraderPoolDeployParameters calldata parameters
    ) internal view returns (ITraderPool.PoolParameters memory poolParameters) {
        (uint256 general, uint256[] memory byPeriod) = _coreProperties.getTraderCommissions();

        require(parameters.trader != address(0), "PoolFactory: invalid trader address");
        require(
            !_coreProperties.isBlacklistedToken(parameters.baseToken),
            "PoolFactory: token is blacklisted"
        );
        require(
            parameters.commissionPercentage >= general &&
                parameters.commissionPercentage <= byPeriod[uint256(parameters.commissionPeriod)],
            "PoolFactory: Incorrect percentage"
        );

        poolParameters = ITraderPool.PoolParameters(
            parameters.descriptionURL,
            parameters.trader,
            parameters.privatePool,
            parameters.totalLPEmission,
            parameters.baseToken,
            ERC20(parameters.baseToken).decimals(),
            parameters.minimalInvestment,
            parameters.commissionPeriod,
            parameters.commissionPercentage
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/pool-contracts-registry/presets/OwnablePoolContractsRegistry.sol";
import "@dlsl/dev-modules/libs/arrays/Paginator.sol";

import "../interfaces/factory/IPoolRegistry.sol";
import "../interfaces/core/IContractsRegistry.sol";

contract PoolRegistry is IPoolRegistry, OwnablePoolContractsRegistry {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Paginator for EnumerableSet.AddressSet;
    using Math for uint256;

    string public constant BASIC_POOL_NAME = "BASIC_POOL";
    string public constant INVEST_POOL_NAME = "INVEST_POOL";
    string public constant RISKY_PROPOSAL_NAME = "RISKY_POOL_PROPOSAL";
    string public constant INVEST_PROPOSAL_NAME = "INVEST_POOL_PROPOSAL";

    string public constant GOV_POOL_NAME = "GOV_POOL";
    string public constant SETTINGS_NAME = "SETTINGS";
    string public constant VALIDATORS_NAME = "VALIDATORS";
    string public constant USER_KEEPER_NAME = "USER_KEEPER";
    string public constant DISTRIBUTION_PROPOSAL_NAME = "DISTRIBUTION_PROPOSAL";

    address internal _poolFactory;

    mapping(address => mapping(string => EnumerableSet.AddressSet)) internal _ownerPools; // pool owner => name => pool

    modifier onlyPoolFactory() {
        _onlyPoolFactory();
        _;
    }

    function setDependencies(address contractsRegistry) public override {
        super.setDependencies(contractsRegistry);

        _poolFactory = IContractsRegistry(contractsRegistry).getPoolFactoryContract();
    }

    function addProxyPool(
        string calldata name,
        address poolAddress
    ) external override onlyPoolFactory {
        _addProxyPool(name, poolAddress);
    }

    function associateUserWithPool(
        address user,
        string calldata name,
        address poolAddress
    ) external onlyPoolFactory {
        _ownerPools[user][name].add(poolAddress);
    }

    function countAssociatedPools(
        address user,
        string calldata name
    ) external view override returns (uint256) {
        return _ownerPools[user][name].length();
    }

    function listAssociatedPools(
        address user,
        string calldata name,
        uint256 offset,
        uint256 limit
    ) external view override returns (address[] memory pools) {
        return _ownerPools[user][name].part(offset, limit);
    }

    function listTraderPoolsWithInfo(
        string calldata name,
        uint256 offset,
        uint256 limit
    )
        external
        view
        override
        returns (
            address[] memory pools,
            ITraderPool.PoolInfo[] memory poolInfos,
            ITraderPool.LeverageInfo[] memory leverageInfos
        )
    {
        pools = _pools[name].part(offset, limit);

        poolInfos = new ITraderPool.PoolInfo[](pools.length);
        leverageInfos = new ITraderPool.LeverageInfo[](pools.length);

        for (uint256 i = 0; i < pools.length; i++) {
            poolInfos[i] = ITraderPool(pools[i]).getPoolInfo();
            leverageInfos[i] = ITraderPool(pools[i]).getLeverageInfo();
        }
    }

    function isBasicPool(address potentialPool) public view override returns (bool) {
        return _isPool(BASIC_POOL_NAME, potentialPool);
    }

    function isInvestPool(address potentialPool) public view override returns (bool) {
        return _isPool(INVEST_POOL_NAME, potentialPool);
    }

    function isTraderPool(address potentialPool) external view override returns (bool) {
        return isBasicPool(potentialPool) || isInvestPool(potentialPool);
    }

    function isGovPool(address potentialPool) external view override returns (bool) {
        return _isPool(GOV_POOL_NAME, potentialPool);
    }

    function _isPool(string memory name, address potentialPool) internal view returns (bool) {
        return _pools[name].contains(potentialPool);
    }

    function _onlyPoolFactory() internal view {
        require(_poolFactory == msg.sender, "PoolRegistry: Caller is not a factory");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../../interfaces/gov/ERC721/IERC721Multiplier.sol";
import "../../core/Globals.sol";

import "../../libs/math/MathHelper.sol";

contract ERC721Multiplier is IERC721Multiplier, ERC721Enumerable, Ownable {
    using MathHelper for uint256;

    string public baseURI;

    mapping(uint256 => NftInfo) private _tokens;
    mapping(address => uint256) private _latestLockedTokenIds;

    event Minted(address to, uint256 tokenId, uint256 multiplier, uint256 duration);
    event Locked(address from, uint256 tokenId, uint256 multiplier, uint256 duration);

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function lock(uint256 tokenId) external override {
        require(
            !isLocked(_latestLockedTokenIds[msg.sender]),
            "ERC721Multiplier: Cannot lock more than one nft"
        );

        _transfer(msg.sender, address(this), tokenId);

        NftInfo storage tokenToBeLocked = _tokens[tokenId];

        tokenToBeLocked.lockedAt = block.timestamp;
        _latestLockedTokenIds[msg.sender] = tokenId;

        emit Locked(msg.sender, tokenId, tokenToBeLocked.multiplier, tokenToBeLocked.duration);
    }

    function mint(address to, uint256 multiplier, uint256 duration) external override onlyOwner {
        uint256 currentTokenId = totalSupply() + 1;

        _mint(to, currentTokenId);

        _tokens[currentTokenId] = NftInfo({
            multiplier: multiplier,
            duration: duration,
            lockedAt: 0
        });

        emit Minted(to, currentTokenId, multiplier, duration);
    }

    function setBaseUri(string calldata uri) external onlyOwner {
        baseURI = uri;
    }

    function getExtraRewards(
        address whose,
        uint256 rewards
    ) external view override returns (uint256) {
        uint256 latestLockedTokenId = _latestLockedTokenIds[whose];

        return
            isLocked(latestLockedTokenId)
                ? rewards.ratio(_tokens[latestLockedTokenId].multiplier, PRECISION)
                : 0;
    }

    function getCurrentMultiplier(
        address whose
    ) external view returns (uint256 multiplier, uint256 timeLeft) {
        uint256 latestLockedTokenId = _latestLockedTokenIds[whose];

        if (!isLocked(latestLockedTokenId)) {
            return (0, 0);
        }

        NftInfo memory info = _tokens[latestLockedTokenId];

        multiplier = info.multiplier;
        timeLeft = info.lockedAt + info.duration - block.timestamp;
    }

    function isLocked(uint256 tokenId) public view override returns (bool) {
        NftInfo memory info = _tokens[tokenId];

        return info.lockedAt != 0 && info.lockedAt + info.duration >= block.timestamp;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721Enumerable, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721Multiplier).interfaceId ||
            ERC721Enumerable.supportsInterface(interfaceId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "../../interfaces/gov/ERC721/IERC721Power.sol";

import "../../libs/math/MathHelper.sol";
import "../../libs/utils/TokenBalance.sol";

import "../../core/Globals.sol";

contract ERC721Power is IERC721Power, ERC721Enumerable, Ownable {
    using SafeERC20 for IERC20;
    using Math for uint256;
    using MathHelper for uint256;
    using DecimalsConverter for uint256;
    using TokenBalance for address;

    uint64 public powerCalcStartTimestamp;
    string public baseURI;

    mapping(uint256 => NftInfo) public nftInfos; // tokenId => info

    uint256 public reductionPercent;

    address public collateralToken;
    uint256 public totalCollateral;

    uint256 public maxPower;
    uint256 public requiredCollateral;

    uint256 public totalPower;

    modifier onlyBeforePowerCalc() {
        _onlyBeforePowerCalc();
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        uint64 startTimestamp,
        address _collateralToken,
        uint256 _maxPower,
        uint256 _reductionPercent,
        uint256 _requiredCollateral
    ) ERC721(name, symbol) {
        require(_collateralToken != address(0), "ERC721Power: zero address");
        require(_maxPower > 0, "ERC721Power: max power can't be zero");
        require(_reductionPercent > 0, "ERC721Power: reduction percent can't be zero");
        require(_reductionPercent < PERCENTAGE_100, "ERC721Power: reduction can't be 100%");
        require(_requiredCollateral > 0, "ERC721Power: required collateral amount can't be zero");

        powerCalcStartTimestamp = startTimestamp;

        collateralToken = _collateralToken;
        maxPower = _maxPower;
        reductionPercent = _reductionPercent;
        requiredCollateral = _requiredCollateral;
    }

    function setNftMaxPower(
        uint256 _maxPower,
        uint256 tokenId
    ) external onlyOwner onlyBeforePowerCalc {
        require(_maxPower > 0, "ERC721Power: max power can't be zero");

        if (_exists(tokenId)) {
            totalPower -= getMaxPowerForNft(tokenId);
            totalPower += _maxPower;
        }

        nftInfos[tokenId].maxPower = _maxPower;
    }

    function setNftRequiredCollateral(
        uint256 amount,
        uint256 tokenId
    ) external onlyOwner onlyBeforePowerCalc {
        require(amount > 0, "ERC721Power: required collateral amount can't be zero");

        nftInfos[tokenId].requiredCollateral = amount;
    }

    function safeMint(address to, uint256 tokenId) external onlyOwner onlyBeforePowerCalc {
        _safeMint(to, tokenId, "");

        totalPower += getMaxPowerForNft(tokenId);
    }

    function setBaseUri(string calldata uri) external onlyOwner {
        baseURI = uri;
    }

    function addCollateral(uint256 amount, uint256 tokenId) external override {
        require(ownerOf(tokenId) == msg.sender, "ERC721Power: sender isn't an nft owner");

        IERC20(collateralToken).safeTransferFrom(
            msg.sender,
            address(this),
            amount.from18(ERC20(collateralToken).decimals())
        );

        recalculateNftPower(tokenId);

        nftInfos[tokenId].currentCollateral += amount;
        totalCollateral += amount;
    }

    function removeCollateral(uint256 amount, uint256 tokenId) external override {
        require(ownerOf(tokenId) == msg.sender, "ERC721Power: sender isn't an nft owner");
        require(
            amount > 0 && amount <= nftInfos[tokenId].currentCollateral,
            "ERC721Power: wrong collateral amount"
        );

        recalculateNftPower(tokenId);

        nftInfos[tokenId].currentCollateral -= amount;
        totalCollateral -= amount;

        IERC20(collateralToken).safeTransfer(
            msg.sender,
            amount.from18(ERC20(collateralToken).decimals())
        );
    }

    function recalculateNftPower(uint256 tokenId) public override returns (uint256 newPower) {
        if (block.timestamp < powerCalcStartTimestamp) {
            return 0;
        }

        newPower = getNftPower(tokenId);

        NftInfo storage nftInfo = nftInfos[tokenId];

        totalPower -= nftInfo.lastUpdate != 0 ? nftInfo.currentPower : getMaxPowerForNft(tokenId);
        totalPower += newPower;

        nftInfo.lastUpdate = uint64(block.timestamp);
        nftInfo.currentPower = newPower;
    }

    function getMaxPowerForNft(uint256 tokenId) public view override returns (uint256) {
        uint256 maxPowerForNft = nftInfos[tokenId].maxPower;

        return maxPowerForNft == 0 ? maxPower : maxPowerForNft;
    }

    function getRequiredCollateralForNft(uint256 tokenId) public view override returns (uint256) {
        uint256 requiredCollateralForNft = nftInfos[tokenId].requiredCollateral;

        return requiredCollateralForNft == 0 ? requiredCollateral : requiredCollateralForNft;
    }

    function getNftPower(uint256 tokenId) public view override returns (uint256) {
        if (block.timestamp <= powerCalcStartTimestamp) {
            return 0;
        }

        uint256 collateral = nftInfos[tokenId].currentCollateral;

        // Calculate the minimum possible power based on the collateral of the nft
        uint256 maxNftPower = getMaxPowerForNft(tokenId);
        uint256 minNftPower = maxNftPower.ratio(collateral, getRequiredCollateralForNft(tokenId));
        minNftPower = maxNftPower.min(minNftPower);

        // Get last update and current power. Or set them to default if it is first iteration
        uint64 lastUpdate = nftInfos[tokenId].lastUpdate;
        uint256 currentPower = nftInfos[tokenId].currentPower;

        if (lastUpdate == 0) {
            lastUpdate = powerCalcStartTimestamp;
            currentPower = maxNftPower;
        }

        // Calculate reduction amount
        uint256 powerReductionPercent = reductionPercent * (block.timestamp - lastUpdate);
        uint256 powerReduction = currentPower.min(maxNftPower.percentage(powerReductionPercent));
        uint256 newPotentialPower = currentPower - powerReduction;

        if (minNftPower <= newPotentialPower) {
            return newPotentialPower;
        }

        if (minNftPower <= currentPower) {
            return minNftPower;
        }

        return currentPower;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC721Enumerable) returns (bool) {
        return
            interfaceId == type(IERC721Power).interfaceId || super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        super._beforeTokenTransfer(from, to, tokenId);

        recalculateNftPower(tokenId);
    }

    function _onlyBeforePowerCalc() internal view {
        require(
            block.timestamp < powerCalcStartTimestamp,
            "ERC721Power: power calculation already begun"
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";

import "../interfaces/gov/settings/IGovSettings.sol";
import "../interfaces/gov/user-keeper/IGovUserKeeper.sol";
import "../interfaces/gov/validators/IGovValidators.sol";
import "../interfaces/gov/IGovPool.sol";
import "../interfaces/core/IContractsRegistry.sol";
import "../interfaces/core/ICoreProperties.sol";

import "../libs/gov-user-keeper/GovUserKeeperLocal.sol";
import "../libs/gov-pool/GovPoolView.sol";
import "../libs/gov-pool/GovPoolCreate.sol";
import "../libs/gov-pool/GovPoolRewards.sol";
import "../libs/gov-pool/GovPoolVote.sol";
import "../libs/gov-pool/GovPoolUnlock.sol";
import "../libs/gov-pool/GovPoolExecute.sol";
import "../libs/math/MathHelper.sol";

import "../core/Globals.sol";

contract GovPool is
    IGovPool,
    AbstractDependant,
    ERC721HolderUpgradeable,
    ERC1155HolderUpgradeable
{
    using MathHelper for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using ShrinkableArray for uint256[];
    using ShrinkableArray for ShrinkableArray.UintArray;
    using GovUserKeeperLocal for *;
    using GovPoolView for *;
    using GovPoolCreate for *;
    using GovPoolRewards for *;
    using GovPoolVote for *;
    using GovPoolUnlock for *;
    using GovPoolExecute for *;

    IGovSettings internal _govSettings;
    IGovUserKeeper internal _govUserKeeper;
    IGovValidators internal _govValidators;
    address internal _distributionProposal;

    ICoreProperties public coreProperties;

    address public nftMultiplier;

    string public descriptionURL;
    string public name;

    uint256 public override latestProposalId;

    mapping(uint256 => Proposal) internal _proposals; // proposalId => info

    mapping(uint256 => mapping(address => mapping(bool => VoteInfo))) internal _voteInfos; // proposalId => voter => isMicropool => info
    mapping(address => mapping(bool => EnumerableSet.UintSet)) internal _votedInProposals; // voter => isMicropool => active proposal ids

    mapping(uint256 => mapping(address => uint256)) public pendingRewards; // proposalId => user => tokens amount

    event Delegated(address from, address to, uint256 amount, uint256[] nfts, bool isDelegate);
    event MovedToValidators(uint256 proposalId, address sender);
    event Deposited(uint256 amount, uint256[] nfts, address sender);
    event Withdrawn(uint256 amount, uint256[] nfts, address sender);

    modifier onlyThis() {
        _onlyThis();
        _;
    }

    function __GovPool_init(
        address govSettingAddress,
        address govUserKeeperAddress,
        address distributionProposalAddress,
        address validatorsAddress,
        address nftMultiplierAddress,
        string calldata _descriptionURL,
        string calldata _name
    ) external initializer {
        _govSettings = IGovSettings(govSettingAddress);
        _govUserKeeper = IGovUserKeeper(govUserKeeperAddress);
        _govValidators = IGovValidators(validatorsAddress);
        _distributionProposal = distributionProposalAddress;

        if (nftMultiplierAddress != address(0)) {
            _setNftMultiplierAddress(nftMultiplierAddress);
        }

        descriptionURL = _descriptionURL;
        name = _name;
    }

    function setDependencies(address contractsRegistry) external override dependant {
        IContractsRegistry registry = IContractsRegistry(contractsRegistry);

        coreProperties = ICoreProperties(registry.getCorePropertiesContract());
    }

    function getHelperContracts()
        external
        view
        override
        returns (
            address settings,
            address userKeeper,
            address validators,
            address distributionProposal
        )
    {
        return (
            address(_govSettings),
            address(_govUserKeeper),
            address(_govValidators),
            _distributionProposal
        );
    }

    function createProposal(
        string calldata _descriptionURL,
        string calldata misc,
        address[] calldata executors,
        uint256[] calldata values,
        bytes[] calldata data
    ) external override {
        latestProposalId++;

        _proposals.createProposal(_descriptionURL, misc, executors, values, data);

        pendingRewards.updateRewards(
            latestProposalId,
            _proposals[latestProposalId].core.settings.creationReward,
            PRECISION
        );
    }

    function moveProposalToValidators(uint256 proposalId) external override {
        _proposals.moveProposalToValidators(proposalId);

        pendingRewards.updateRewards(
            proposalId,
            _proposals[proposalId].core.settings.creationReward,
            PRECISION
        );

        emit MovedToValidators(proposalId, msg.sender);
    }

    function vote(
        uint256 proposalId,
        uint256 depositAmount,
        uint256[] calldata depositNftIds,
        uint256 voteAmount,
        uint256[] calldata voteNftIds
    ) external override {
        _govUserKeeper.depositTokens.exec(msg.sender, depositAmount);
        _govUserKeeper.depositNfts.exec(msg.sender, depositNftIds);

        unlock(msg.sender, false);

        uint256 reward = _proposals.vote(
            _votedInProposals,
            _voteInfos,
            proposalId,
            voteAmount,
            voteNftIds
        );

        pendingRewards.updateRewards(
            proposalId,
            reward,
            _proposals[proposalId].core.settings.voteRewardsCoefficient
        );
    }

    function voteDelegated(
        uint256 proposalId,
        uint256 voteAmount,
        uint256[] calldata voteNftIds
    ) external override {
        unlock(msg.sender, true);

        uint256 reward = _proposals.voteDelegated(
            _votedInProposals,
            _voteInfos,
            proposalId,
            voteAmount,
            voteNftIds
        );

        pendingRewards.updateRewards(
            proposalId,
            reward,
            _proposals[proposalId].core.settings.voteRewardsCoefficient
        );
    }

    function deposit(address receiver, uint256 amount, uint256[] calldata nftIds) public override {
        require(amount > 0 || nftIds.length > 0, "Gov: empty deposit");

        _govUserKeeper.depositTokens.exec(receiver, amount);
        _govUserKeeper.depositNfts.exec(receiver, nftIds);

        emit Deposited(amount, nftIds, receiver);
    }

    function withdraw(
        address receiver,
        uint256 amount,
        uint256[] calldata nftIds
    ) external override {
        require(amount > 0 || nftIds.length > 0, "Gov: empty withdrawal");

        unlock(msg.sender, false);

        _govUserKeeper.withdrawTokens.exec(receiver, amount);
        _govUserKeeper.withdrawNfts.exec(receiver, nftIds);

        emit Withdrawn(amount, nftIds, receiver);
    }

    function delegate(
        address delegatee,
        uint256 amount,
        uint256[] calldata nftIds
    ) external override {
        require(amount > 0 || nftIds.length > 0, "Gov: empty delegation");

        unlock(msg.sender, false);

        _govUserKeeper.delegateTokens.exec(delegatee, amount);
        _govUserKeeper.delegateNfts.exec(delegatee, nftIds);

        emit Delegated(msg.sender, delegatee, amount, nftIds, true);
    }

    function undelegate(
        address delegatee,
        uint256 amount,
        uint256[] calldata nftIds
    ) external override {
        require(amount > 0 || nftIds.length > 0, "Gov: empty undelegation");

        unlock(delegatee, true);

        _govUserKeeper.undelegateTokens.exec(delegatee, amount);
        _govUserKeeper.undelegateNfts.exec(delegatee, nftIds);

        emit Delegated(msg.sender, delegatee, amount, nftIds, false);
    }

    function unlock(address user, bool isMicropool) public override {
        unlockInProposals(_votedInProposals[user][isMicropool].values(), user, isMicropool);
    }

    function unlockInProposals(
        uint256[] memory proposalIds,
        address user,
        bool isMicropool
    ) public override {
        _votedInProposals.unlockInProposals(_voteInfos, proposalIds, user, isMicropool);
    }

    function execute(uint256 proposalId) public override {
        _proposals.execute(proposalId);

        pendingRewards.updateRewards(
            proposalId,
            _proposals[proposalId].core.settings.executionReward,
            PRECISION
        );
    }

    function claimRewards(uint256[] calldata proposalIds) external override {
        for (uint256 i; i < proposalIds.length; i++) {
            pendingRewards.claimReward(_proposals, proposalIds[i]);
        }
    }

    function executeAndClaim(uint256 proposalId) external override {
        execute(proposalId);
        pendingRewards.claimReward(_proposals, proposalId);
    }

    function editDescriptionURL(string calldata newDescriptionURL) external override onlyThis {
        descriptionURL = newDescriptionURL;
    }

    function setNftMultiplierAddress(address nftMultiplierAddress) external override onlyThis {
        _setNftMultiplierAddress(nftMultiplierAddress);
    }

    receive() external payable {}

    function getProposals(
        uint256 offset,
        uint256 limit
    ) external view returns (ProposalView[] memory proposals) {
        return _proposals.getProposals(offset, limit);
    }

    function getProposalState(uint256 proposalId) public view override returns (ProposalState) {
        ProposalCore storage core = _proposals[proposalId].core;

        uint64 voteEnd = core.voteEnd;

        if (voteEnd == 0) {
            return ProposalState.Undefined;
        }

        if (core.executed) {
            return ProposalState.Executed;
        }

        if (core.settings.earlyCompletion || voteEnd < block.timestamp) {
            if (_quorumReached(core)) {
                if (core.settings.validatorsVote && _govValidators.validatorsCount() > 0) {
                    IGovValidators.ProposalState status = _govValidators.getProposalState(
                        proposalId,
                        false
                    );

                    if (status == IGovValidators.ProposalState.Undefined) {
                        return ProposalState.WaitingForVotingTransfer;
                    }

                    if (status == IGovValidators.ProposalState.Succeeded) {
                        return ProposalState.Succeeded;
                    }

                    if (status == IGovValidators.ProposalState.Defeated) {
                        return ProposalState.Defeated;
                    }

                    return ProposalState.ValidatorVoting;
                } else {
                    return ProposalState.Succeeded;
                }
            }

            if (voteEnd < block.timestamp) {
                return ProposalState.Defeated;
            }
        }

        return ProposalState.Voting;
    }

    function getProposalRequiredQuorum(
        uint256 proposalId
    ) external view override returns (uint256) {
        ProposalCore storage core = _proposals[proposalId].core;

        if (core.voteEnd == 0) {
            return 0;
        }

        return _govUserKeeper.getTotalVoteWeight().ratio(core.settings.quorum, PERCENTAGE_100);
    }

    function getTotalVotes(
        uint256 proposalId,
        address voter,
        bool isMicropool
    ) external view override returns (uint256, uint256) {
        return (
            _proposals[proposalId].core.votesFor,
            _voteInfos[proposalId][voter][isMicropool].totalVoted
        );
    }

    function getUserVotes(
        uint256 proposalId,
        address voter,
        bool isMicropool
    ) external view returns (VoteInfoView memory voteInfo) {
        VoteInfo storage info = _voteInfos[proposalId][voter][isMicropool];

        return
            VoteInfoView({
                totalVoted: info.totalVoted,
                tokensVoted: info.tokensVoted,
                nftsVoted: info.nftsVoted.values()
            });
    }

    function getWithdrawableAssets(
        address delegator,
        address delegatee
    ) external view override returns (uint256 tokens, ShrinkableArray.UintArray memory nfts) {
        return
            delegatee == address(0)
                ? delegator.getWithdrawableAssets(_votedInProposals, _voteInfos)
                : delegator.getUndelegateableAssets(delegatee, _votedInProposals, _voteInfos);
    }

    function _setNftMultiplierAddress(address nftMultiplierAddress) internal {
        require(nftMultiplier == address(0), "Gov: current nft address isn't zero");
        require(nftMultiplierAddress != address(0), "Gov: new nft address is zero");

        nftMultiplier = nftMultiplierAddress;
    }

    function _quorumReached(ProposalCore storage core) internal view returns (bool) {
        return
            PERCENTAGE_100.ratio(core.votesFor, _govUserKeeper.getTotalVoteWeight()) >=
            core.settings.quorum;
    }

    function _onlyThis() internal view {
        require(address(this) == msg.sender, "Gov: not this contract");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "../../interfaces/gov/IGovPool.sol";
import "../../interfaces/gov/proposals/IDistributionProposal.sol";

import "../../libs/math/MathHelper.sol";
import "../../libs/utils/TokenBalance.sol";

import "../../core/Globals.sol";

contract DistributionProposal is IDistributionProposal, Initializable {
    using SafeERC20 for IERC20Metadata;
    using MathHelper for uint256;
    using DecimalsConverter for uint256;
    using TokenBalance for address;

    address public govAddress;

    mapping(uint256 => IDistributionProposal.DistributionProposalStruct) public proposals;

    event DistributionProposalClaimed(uint256 proposalId, address sender, uint256 amount);

    modifier onlyGov() {
        require(msg.sender == govAddress, "DP: not a Gov contract");
        _;
    }

    function __DistributionProposal_init(address _govAddress) external initializer {
        require(_govAddress != address(0), "DP: _govAddress is zero");

        govAddress = _govAddress;
    }

    function execute(
        uint256 proposalId,
        address token,
        uint256 amount
    ) external payable override onlyGov {
        require(proposals[proposalId].rewardAddress == address(0), "DP: proposal already exists");
        require(token != address(0), "DP: zero address");
        require(amount > 0, "DP: zero amount");

        proposals[proposalId].rewardAddress = token;
        proposals[proposalId].rewardAmount = amount;
    }

    function claim(address voter, uint256[] calldata proposalIds) external override {
        require(proposalIds.length > 0, "DP: zero array length");
        require(voter != address(0), "DP: zero address");

        for (uint256 i; i < proposalIds.length; i++) {
            DistributionProposalStruct storage dpInfo = proposals[proposalIds[i]];
            IERC20Metadata rewardToken = IERC20Metadata(dpInfo.rewardAddress);

            require(address(rewardToken) != address(0), "DP: zero address");
            require(!dpInfo.claimed[voter], "DP: already claimed");

            uint256 reward = getPotentialReward(proposalIds[i], voter, dpInfo.rewardAmount);
            uint256 balance = address(rewardToken).thisBalance();

            dpInfo.claimed[voter] = true;

            if (address(rewardToken) == ETHEREUM_ADDRESS) {
                (bool status, ) = payable(voter).call{value: reward}("");
                require(status, "DP: failed to send eth");
            } else {
                if (balance < reward) {
                    rewardToken.safeTransferFrom(govAddress, address(this), reward - balance);
                }

                rewardToken.safeTransfer(voter, reward);

                reward = reward.to18(rewardToken.decimals());
            }

            emit DistributionProposalClaimed(proposalIds[i], voter, reward);
        }
    }

    receive() external payable {}

    function getPotentialReward(
        uint256 proposalId,
        address voter,
        uint256 rewardAmount
    ) public view override returns (uint256) {
        (uint256 totalVoteWeight, uint256 voteWeight) = IGovPool(govAddress).getTotalVotes(
            proposalId,
            voter,
            false
        );

        return totalVoteWeight == 0 ? 0 : rewardAmount.ratio(voteWeight, totalVoteWeight);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../../interfaces/gov/settings/IGovSettings.sol";

import "../../core/Globals.sol";

contract GovSettings is IGovSettings, OwnableUpgradeable {
    uint256 public newSettingsId;

    mapping(uint256 => ProposalSettings) public settings; // settingsId => info
    mapping(address => uint256) public executorToSettings; // executor => seetingsId

    event SettingsChanged(uint256 settingsId, string description);
    event ExecutorChanged(uint256 settingsId, address executor);

    function __GovSettings_init(
        address govPoolAddress,
        address distributionProposalAddress,
        address validatorsAddress,
        address govUserKeeperAddress,
        ProposalSettings[] calldata proposalSettings,
        address[] calldata additionalProposalExecutors
    ) external initializer {
        __Ownable_init();

        uint256 systemExecutors = uint256(ExecutorType.VALIDATORS);
        uint256 settingsId;

        for (uint256 i = 0; i < proposalSettings.length; i++) {
            ProposalSettings calldata executorSettings = proposalSettings[i];

            _validateProposalSettings(executorSettings);

            settings[settingsId] = executorSettings;

            if (settingsId == uint256(ExecutorType.INTERNAL)) {
                _setExecutor(address(this), settingsId);
                _setExecutor(govPoolAddress, settingsId);
                _setExecutor(govUserKeeperAddress, settingsId);
            } else if (settingsId == uint256(ExecutorType.DISTRIBUTION)) {
                require(
                    !executorSettings.delegatedVotingAllowed && !executorSettings.earlyCompletion,
                    "GovSettings: invalid distribution settings"
                );
                _setExecutor(distributionProposalAddress, settingsId);
            } else if (settingsId == uint256(ExecutorType.VALIDATORS)) {
                _setExecutor(validatorsAddress, settingsId);
            } else if (settingsId > systemExecutors) {
                _setExecutor(
                    additionalProposalExecutors[settingsId - systemExecutors - 1],
                    settingsId
                );
            }

            settingsId++;
        }
        newSettingsId = settingsId;
    }

    function addSettings(ProposalSettings[] calldata _settings) external override onlyOwner {
        uint256 settingsId = newSettingsId;

        for (uint256 i; i < _settings.length; i++) {
            _validateProposalSettings(_settings[i]);
            _setSettings(_settings[i], settingsId++);
        }

        newSettingsId = settingsId;
    }

    function editSettings(
        uint256[] calldata settingsIds,
        ProposalSettings[] calldata _settings
    ) external override onlyOwner {
        for (uint256 i; i < _settings.length; i++) {
            require(_settingsExist(settingsIds[i]), "GovSettings: settings do not exist");

            _validateProposalSettings(_settings[i]);
            _setSettings(_settings[i], settingsIds[i]);
        }
    }

    function changeExecutors(
        address[] calldata executors,
        uint256[] calldata settingsIds
    ) external override onlyOwner {
        for (uint256 i; i < executors.length; i++) {
            require(_settingsExist(settingsIds[i]), "GovSettings: settings do not exist");

            _setExecutor(executors[i], settingsIds[i]);
        }
    }

    function _validateProposalSettings(ProposalSettings calldata _settings) internal pure {
        require(_settings.duration > 0, "GovSettings: invalid vote duration value");
        require(_settings.quorum <= PERCENTAGE_100, "GovSettings: invalid quorum value");
        require(
            _settings.durationValidators > 0,
            "GovSettings: invalid validator vote duration value"
        );
        require(
            _settings.quorumValidators <= PERCENTAGE_100,
            "GovSettings: invalid validator quorum value"
        );
    }

    function _settingsExist(uint256 settingsId) internal view returns (bool) {
        return settings[settingsId].duration > 0;
    }

    function getDefaultSettings() external view override returns (ProposalSettings memory) {
        return settings[uint256(ExecutorType.DEFAULT)];
    }

    function getExecutorSettings(
        address executor
    ) external view override returns (ProposalSettings memory) {
        return settings[executorToSettings[executor]];
    }

    function _setExecutor(address executor, uint256 settingsId) internal {
        executorToSettings[executor] = settingsId;

        emit ExecutorChanged(settingsId, executor);
    }

    function _setSettings(ProposalSettings calldata _settings, uint256 settingsId) internal {
        settings[settingsId] = _settings;

        emit SettingsChanged(settingsId, _settings.executorDescription);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";
import "@dlsl/dev-modules/libs/arrays/Paginator.sol";
import "@dlsl/dev-modules/libs/arrays/ArrayHelper.sol";

import "../../interfaces/gov/user-keeper/IGovUserKeeper.sol";
import "../../interfaces/gov/IGovPool.sol";

import "../../libs/math/MathHelper.sol";
import "../../libs/gov-user-keeper/GovUserKeeperView.sol";

import "../ERC721/ERC721Power.sol";

contract GovUserKeeper is IGovUserKeeper, OwnableUpgradeable, ERC721HolderUpgradeable {
    using SafeERC20 for IERC20;
    using Math for uint256;
    using MathHelper for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using ShrinkableArray for uint256[];
    using ShrinkableArray for ShrinkableArray.UintArray;
    using ArrayHelper for uint256[];
    using Paginator for EnumerableSet.UintSet;
    using DecimalsConverter for uint256;
    using GovUserKeeperView for *;

    address public tokenAddress;
    address public nftAddress;

    NFTInfo internal _nftInfo;

    uint256 internal _latestPowerSnapshotId;

    mapping(address => UserInfo) internal _usersInfo; // user => info
    mapping(address => BalanceInfo) internal _micropoolsInfo; // user = micropool address => info

    mapping(uint256 => uint256) internal _nftLockedNums; // tokenId => locked num

    mapping(uint256 => uint256) public nftSnapshot; // snapshot id => totalNftsPower

    event SetERC20(address token);
    event SetERC721(address token);

    modifier withSupportedToken() {
        _withSupportedToken();
        _;
    }

    modifier withSupportedNft() {
        _withSupportedNft();
        _;
    }

    function __GovUserKeeper_init(
        address _tokenAddress,
        address _nftAddress,
        uint256 totalPowerInTokens,
        uint256 nftsTotalSupply
    ) external initializer {
        __Ownable_init();
        __ERC721Holder_init();

        require(_tokenAddress != address(0) || _nftAddress != address(0), "GovUK: zero addresses");

        if (_nftAddress != address(0)) {
            _setERC721Address(_nftAddress, totalPowerInTokens, nftsTotalSupply);
        }

        if (_tokenAddress != address(0)) {
            _setERC20Address(_tokenAddress);
        }
    }

    function depositTokens(
        address payer,
        address receiver,
        uint256 amount
    ) external override onlyOwner withSupportedToken {
        address token = tokenAddress;

        IERC20(token).safeTransferFrom(
            payer,
            address(this),
            amount.from18(ERC20(token).decimals())
        );

        _usersInfo[receiver].balanceInfo.tokenBalance += amount;
    }

    function withdrawTokens(
        address payer,
        address receiver,
        uint256 amount
    ) external override onlyOwner withSupportedToken {
        BalanceInfo storage payerBalanceInfo = _usersInfo[payer].balanceInfo;

        address token = tokenAddress;
        uint256 balance = payerBalanceInfo.tokenBalance;
        uint256 availableBalance = balance.max(payerBalanceInfo.maxTokensLocked) -
            payerBalanceInfo.maxTokensLocked;

        require(amount <= availableBalance, "GovUK: can't withdraw this");

        payerBalanceInfo.tokenBalance = balance - amount;

        IERC20(token).safeTransfer(receiver, amount.from18(ERC20(token).decimals()));
    }

    function delegateTokens(
        address delegator,
        address delegatee,
        uint256 amount
    ) external override onlyOwner withSupportedToken {
        UserInfo storage delegatorInfo = _usersInfo[delegator];

        uint256 balance = delegatorInfo.balanceInfo.tokenBalance;
        uint256 availableBalance = balance.max(delegatorInfo.balanceInfo.maxTokensLocked) -
            delegatorInfo.balanceInfo.maxTokensLocked;

        require(amount <= availableBalance, "GovUK: overdelegation");

        delegatorInfo.balanceInfo.tokenBalance = balance - amount;

        delegatorInfo.delegatees.add(delegatee);
        delegatorInfo.delegatedTokens[delegatee] += amount;

        _micropoolsInfo[delegatee].tokenBalance += amount;
    }

    function undelegateTokens(
        address delegator,
        address delegatee,
        uint256 amount
    ) external override onlyOwner withSupportedToken {
        UserInfo storage delegatorInfo = _usersInfo[delegator];
        BalanceInfo storage micropoolInfo = _micropoolsInfo[delegatee];

        uint256 delegated = delegatorInfo.delegatedTokens[delegatee];
        uint256 availableAmount = micropoolInfo.tokenBalance - micropoolInfo.maxTokensLocked;

        require(
            amount <= delegated && amount <= availableAmount,
            "GovUK: amount exceeds delegation"
        );

        micropoolInfo.tokenBalance -= amount;

        delegatorInfo.balanceInfo.tokenBalance += amount;
        delegatorInfo.delegatedTokens[delegatee] -= amount;

        if (
            delegatorInfo.delegatedTokens[delegatee] == 0 &&
            delegatorInfo.delegatedNfts[delegatee].length() == 0
        ) {
            delegatorInfo.delegatees.remove(delegatee);
        }
    }

    function depositNfts(
        address payer,
        address receiver,
        uint256[] calldata nftIds
    ) external override onlyOwner withSupportedNft {
        BalanceInfo storage receiverInfo = _usersInfo[receiver].balanceInfo;

        IERC721 nft = IERC721(nftAddress);

        for (uint256 i; i < nftIds.length; i++) {
            nft.safeTransferFrom(payer, address(this), nftIds[i]);

            receiverInfo.nftBalance.add(nftIds[i]);
        }
    }

    function withdrawNfts(
        address payer,
        address receiver,
        uint256[] calldata nftIds
    ) external override onlyOwner withSupportedNft {
        BalanceInfo storage payerInfo = _usersInfo[payer].balanceInfo;

        IERC721 nft = IERC721(nftAddress);

        for (uint256 i; i < nftIds.length; i++) {
            require(
                payerInfo.nftBalance.contains(nftIds[i]) && _nftLockedNums[nftIds[i]] == 0,
                "GovUK: NFT is not owned or locked"
            );

            payerInfo.nftBalance.remove(nftIds[i]);

            nft.safeTransferFrom(address(this), receiver, nftIds[i]);
        }
    }

    function delegateNfts(
        address delegator,
        address delegatee,
        uint256[] calldata nftIds
    ) external override onlyOwner withSupportedNft {
        UserInfo storage delegatorInfo = _usersInfo[delegator];
        BalanceInfo storage micropoolInfo = _micropoolsInfo[delegatee];

        for (uint256 i; i < nftIds.length; i++) {
            require(
                delegatorInfo.balanceInfo.nftBalance.contains(nftIds[i]) &&
                    _nftLockedNums[nftIds[i]] == 0,
                "GovUK: NFT is not owned or locked"
            );

            delegatorInfo.balanceInfo.nftBalance.remove(nftIds[i]);

            delegatorInfo.delegatees.add(delegatee);
            delegatorInfo.delegatedNfts[delegatee].add(nftIds[i]);

            micropoolInfo.nftBalance.add(nftIds[i]);
        }
    }

    function undelegateNfts(
        address delegator,
        address delegatee,
        uint256[] calldata nftIds
    ) external override onlyOwner withSupportedNft {
        UserInfo storage delegatorInfo = _usersInfo[delegator];
        BalanceInfo storage micropoolInfo = _micropoolsInfo[delegatee];

        for (uint256 i; i < nftIds.length; i++) {
            require(
                delegatorInfo.delegatedNfts[delegatee].contains(nftIds[i]) &&
                    _nftLockedNums[nftIds[i]] == 0,
                "GovUK: NFT is not owned or locked"
            );

            micropoolInfo.nftBalance.remove(nftIds[i]);

            delegatorInfo.balanceInfo.nftBalance.add(nftIds[i]);
            delegatorInfo.delegatedNfts[delegatee].remove(nftIds[i]);
        }

        if (
            delegatorInfo.delegatedTokens[delegatee] == 0 &&
            delegatorInfo.delegatedNfts[delegatee].length() == 0
        ) {
            delegatorInfo.delegatees.remove(delegatee);
        }
    }

    function createNftPowerSnapshot() external override onlyOwner returns (uint256) {
        IERC721Power nftContract = IERC721Power(nftAddress);

        if (address(nftContract) == address(0)) {
            return 0;
        }

        uint256 currentPowerSnapshotId = ++_latestPowerSnapshotId;
        uint256 power;

        if (_nftInfo.isSupportPower) {
            power = nftContract.totalPower();
        } else if (_nftInfo.totalSupply == 0) {
            power = nftContract.totalSupply();
        } else {
            power = _nftInfo.totalSupply;
        }

        nftSnapshot[currentPowerSnapshotId] = power;

        return currentPowerSnapshotId;
    }

    function updateMaxTokenLockedAmount(
        uint256[] calldata lockedProposals,
        address voter,
        bool isMicropool
    ) external override onlyOwner {
        BalanceInfo storage balanceInfo = _getBalanceInfoStorage(voter, isMicropool);

        uint256 lockedAmount = balanceInfo.maxTokensLocked;
        uint256 newLockedAmount;

        for (uint256 i; i < lockedProposals.length; i++) {
            newLockedAmount = newLockedAmount.max(
                balanceInfo.lockedInProposals[lockedProposals[i]]
            );

            if (newLockedAmount == lockedAmount) {
                break;
            }
        }

        balanceInfo.maxTokensLocked = newLockedAmount;
    }

    function lockTokens(
        uint256 proposalId,
        address voter,
        bool isMicropool,
        uint256 amount
    ) external override onlyOwner {
        BalanceInfo storage balanceInfo = _getBalanceInfoStorage(voter, isMicropool);

        balanceInfo.lockedInProposals[proposalId] += amount;

        balanceInfo.maxTokensLocked = balanceInfo.maxTokensLocked.max(
            balanceInfo.lockedInProposals[proposalId]
        );
    }

    function unlockTokens(
        uint256 proposalId,
        address voter,
        bool isMicropool
    ) external override onlyOwner returns (uint256 unlockedAmount) {
        unlockedAmount = _getBalanceInfoStorage(voter, isMicropool).lockedInProposals[proposalId];

        delete _getBalanceInfoStorage(voter, isMicropool).lockedInProposals[proposalId];
    }

    function lockNfts(
        address voter,
        bool isMicropool,
        bool useDelegated,
        uint256[] calldata nftIds
    ) external override onlyOwner {
        BalanceInfo storage balanceInfo = _getBalanceInfoStorage(voter, isMicropool);

        for (uint256 i; i < nftIds.length; i++) {
            bool userContains = balanceInfo.nftBalance.contains(nftIds[i]);
            bool delegatedContains;

            if (!userContains && !isMicropool && useDelegated) {
                UserInfo storage userInfo = _usersInfo[voter];

                uint256 delegateeLength = userInfo.delegatees.length();

                for (uint256 j; j < delegateeLength; j++) {
                    if (userInfo.delegatedNfts[userInfo.delegatees.at(j)].contains(nftIds[i])) {
                        delegatedContains = true;
                        break;
                    }
                }
            }

            require(userContains || delegatedContains, "GovUK: NFT is not owned");

            _nftLockedNums[nftIds[i]]++;
        }
    }

    function unlockNfts(uint256[] calldata nftIds) external override onlyOwner {
        for (uint256 i; i < nftIds.length; i++) {
            require(_nftLockedNums[nftIds[i]] > 0, "GovUK: NFT is not locked");

            _nftLockedNums[nftIds[i]]--;
        }
    }

    function updateNftPowers(uint256[] calldata nftIds) external override onlyOwner {
        if (!_nftInfo.isSupportPower) {
            return;
        }

        ERC721Power nftContract = ERC721Power(nftAddress);

        for (uint256 i = 0; i < nftIds.length; i++) {
            nftContract.recalculateNftPower(nftIds[i]);
        }
    }

    function setERC20Address(address _tokenAddress) external override onlyOwner {
        _setERC20Address(_tokenAddress);
    }

    function setERC721Address(
        address _nftAddress,
        uint256 totalPowerInTokens,
        uint256 nftsTotalSupply
    ) external override onlyOwner {
        _setERC721Address(_nftAddress, totalPowerInTokens, nftsTotalSupply);
    }

    function getNftInfo() external view override returns (NFTInfo memory) {
        return _nftInfo;
    }

    function maxLockedAmount(
        address voter,
        bool isMicropool
    ) external view override returns (uint256) {
        return _getBalanceInfoStorage(voter, isMicropool).maxTokensLocked;
    }

    function tokenBalance(
        address voter,
        bool isMicropool,
        bool useDelegated
    ) public view override returns (uint256 totalBalance, uint256 ownedBalance) {
        if (tokenAddress == address(0)) {
            return (0, 0);
        }

        totalBalance = _getBalanceInfoStorage(voter, isMicropool).tokenBalance;

        if (!isMicropool) {
            if (useDelegated) {
                UserInfo storage userInfo = _usersInfo[voter];

                uint256 delegateeLength = userInfo.delegatees.length();

                for (uint256 i; i < delegateeLength; i++) {
                    totalBalance += userInfo.delegatedTokens[userInfo.delegatees.at(i)];
                }
            }

            ownedBalance = ERC20(tokenAddress).balanceOf(voter).to18(
                ERC20(tokenAddress).decimals()
            );
            totalBalance += ownedBalance;
        }
    }

    function nftBalance(
        address voter,
        bool isMicropool,
        bool useDelegated
    ) public view override returns (uint256 totalBalance, uint256 ownedBalance) {
        if (nftAddress == address(0)) {
            return (0, 0);
        }

        totalBalance = _getBalanceInfoStorage(voter, isMicropool).nftBalance.length();

        if (!isMicropool) {
            if (useDelegated) {
                UserInfo storage userInfo = _usersInfo[voter];

                uint256 delegateeLength = userInfo.delegatees.length();

                for (uint256 i; i < delegateeLength; i++) {
                    totalBalance += userInfo.delegatedNfts[userInfo.delegatees.at(i)].length();
                }
            }

            ownedBalance = ERC721(nftAddress).balanceOf(voter);
            totalBalance += ownedBalance;
        }
    }

    function nftExactBalance(
        address voter,
        bool isMicropool,
        bool useDelegated
    ) public view override returns (uint256[] memory nfts, uint256 ownedLength) {
        uint256 length;
        (length, ownedLength) = nftBalance(voter, isMicropool, useDelegated);

        if (length == 0) {
            return (nfts, 0);
        }

        uint256 currentLength;
        nfts = new uint256[](length);

        currentLength = nfts.insert(
            currentLength,
            _getBalanceInfoStorage(voter, isMicropool).nftBalance.values()
        );

        if (!isMicropool) {
            if (useDelegated) {
                UserInfo storage userInfo = _usersInfo[voter];

                uint256 delegateeLength = userInfo.delegatees.length();

                for (uint256 i; i < delegateeLength; i++) {
                    currentLength = nfts.insert(
                        currentLength,
                        userInfo.delegatedNfts[userInfo.delegatees.at(i)].values()
                    );
                }
            }

            if (_nftInfo.totalSupply == 0) {
                ERC721Power nftContract = ERC721Power(nftAddress);

                for (uint256 i; i < ownedLength; i++) {
                    nfts[currentLength++] = nftContract.tokenOfOwnerByIndex(voter, i);
                }
            }
        }
    }

    function getNftsPowerInTokensBySnapshot(
        uint256[] memory nftIds,
        uint256 snapshotId
    ) public view override returns (uint256) {
        uint256 totalNftsPower = nftSnapshot[snapshotId];

        ERC721Power nftContract = ERC721Power(nftAddress);

        if (address(nftContract) == address(0) || totalNftsPower == 0) {
            return 0;
        }

        uint256 nftsPower;

        if (!_nftInfo.isSupportPower) {
            nftsPower = nftIds.length.ratio(_nftInfo.totalPowerInTokens, totalNftsPower);
        } else {
            uint256 totalPowerInTokens = _nftInfo.totalPowerInTokens;

            for (uint256 i; i < nftIds.length; i++) {
                uint256 power = nftContract.getNftPower(nftIds[i]);
                nftsPower += totalPowerInTokens.ratio(power, totalNftsPower);
            }
        }

        return nftsPower;
    }

    function getTotalVoteWeight() external view override returns (uint256) {
        address token = tokenAddress;

        return
            (token != address(0) ? IERC20(token).totalSupply().to18(ERC20(token).decimals()) : 0) +
            _nftInfo.totalPowerInTokens;
    }

    function canParticipate(
        address voter,
        bool isMicropool,
        bool useDelegated,
        uint256 requiredVotes,
        uint256 snapshotId
    ) external view override returns (bool) {
        (uint256 tokens, ) = tokenBalance(voter, isMicropool, useDelegated);

        if (tokens >= requiredVotes) {
            return true;
        }

        (uint256[] memory nftIds, ) = nftExactBalance(voter, isMicropool, useDelegated);
        uint256 nftPower = getNftsPowerInTokensBySnapshot(nftIds, snapshotId);

        return tokens + nftPower >= requiredVotes;
    }

    function votingPower(
        address[] calldata users,
        bool[] calldata isMicropools,
        bool[] calldata useDelegated
    ) external view override returns (VotingPowerView[] memory votingPowers) {
        return users.votingPower(isMicropools, useDelegated);
    }

    function nftVotingPower(
        uint256[] memory nftIds
    ) external view override returns (uint256 nftPower, uint256[] memory perNftPower) {
        return nftIds.nftVotingPower();
    }

    function delegations(
        address user
    ) external view override returns (uint256 power, DelegationInfoView[] memory delegationsInfo) {
        return user.delegations(_usersInfo);
    }

    function getUndelegateableAssets(
        address delegator,
        address delegatee,
        ShrinkableArray.UintArray calldata lockedProposals,
        uint256[] calldata unlockedNfts
    )
        external
        view
        override
        returns (uint256 undelegateableTokens, ShrinkableArray.UintArray memory undelegateableNfts)
    {
        return
            delegatee.getUndelegateableAssets(
                lockedProposals,
                unlockedNfts,
                _getBalanceInfoStorage(delegatee, true),
                _usersInfo[delegator],
                _nftLockedNums
            );
    }

    function getWithdrawableAssets(
        address voter,
        ShrinkableArray.UintArray calldata lockedProposals,
        uint256[] calldata unlockedNfts
    )
        external
        view
        override
        returns (uint256 withdrawableTokens, ShrinkableArray.UintArray memory withdrawableNfts)
    {
        return
            lockedProposals.getWithdrawableAssets(
                unlockedNfts,
                _getBalanceInfoStorage(voter, false),
                _nftLockedNums
            );
    }

    function _setERC20Address(address _tokenAddress) internal {
        require(tokenAddress == address(0), "GovUK: current token address isn't zero");
        require(_tokenAddress != address(0), "GovUK: new token address is zero");

        tokenAddress = _tokenAddress;

        emit SetERC20(_tokenAddress);
    }

    function _setERC721Address(
        address _nftAddress,
        uint256 totalPowerInTokens,
        uint256 nftsTotalSupply
    ) internal {
        require(nftAddress == address(0), "GovUK: current token address isn't zero");
        require(_nftAddress != address(0), "GovUK: new token address is zero");
        require(totalPowerInTokens > 0, "GovUK: the equivalent is zero");

        _nftInfo.totalPowerInTokens = totalPowerInTokens;

        if (!IERC165(_nftAddress).supportsInterface(type(IERC721Power).interfaceId)) {
            if (!IERC165(_nftAddress).supportsInterface(type(IERC721Enumerable).interfaceId)) {
                require(nftsTotalSupply > 0, "GovUK: total supply is zero");

                _nftInfo.totalSupply = uint128(nftsTotalSupply);
            }
        } else {
            _nftInfo.isSupportPower = true;
        }

        nftAddress = _nftAddress;

        emit SetERC721(_nftAddress);
    }

    function _getBalanceInfoStorage(
        address voter,
        bool isMicropool
    ) internal view returns (BalanceInfo storage) {
        return isMicropool ? _micropoolsInfo[voter] : _usersInfo[voter].balanceInfo;
    }

    function _withSupportedToken() internal view {
        require(tokenAddress != address(0), "GovUK: token is not supported");
    }

    function _withSupportedNft() internal view {
        require(nftAddress != address(0), "GovUK: nft is not supported");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../../interfaces/gov/validators/IGovValidators.sol";

import "./GovValidatorsToken.sol";

import "../../libs/math/MathHelper.sol";
import "../../core/Globals.sol";

contract GovValidators is IGovValidators, OwnableUpgradeable {
    using Math for uint256;
    using MathHelper for uint256;

    GovValidatorsToken public govValidatorsToken;

    InternalProposalSettings public internalProposalSettings;

    uint256 public override latestInternalProposalId;
    uint256 public validatorsCount;

    mapping(uint256 => InternalProposal) internal _internalProposals; // proposalId => info
    mapping(uint256 => ExternalProposal) internal _externalProposals; // proposalId => info

    mapping(uint256 => mapping(bool => mapping(address => uint256))) public addressVoted; // proposalId => isInternal => user => voted amount

    event ExternalProposalCreated(uint256 proposalId, uint256 quorum);
    event InternalProposalCreated(
        uint256 proposalId,
        string proposalDescription,
        uint256 quorum,
        address sender
    );
    event InternalProposalExecuted(uint256 proposalId, address executor);

    event Voted(uint256 proposalId, address sender, uint256 vote, bool isInternal);
    event ChangedValidatorsBalances(address[] validators, uint256[] newBalance);

    /// @dev Access only for addresses that have validator tokens
    modifier onlyValidator() {
        _onlyValidator();
        _;
    }

    function __GovValidators_init(
        string calldata name,
        string calldata symbol,
        uint64 duration,
        uint128 quorum,
        address[] calldata validators,
        uint256[] calldata balances
    ) external initializer {
        __Ownable_init();

        require(validators.length == balances.length, "Validators: invalid array length");
        require(duration > 0, "Validators: duration is zero");
        require(quorum <= PERCENTAGE_100, "Validators: invalid quorum value");

        govValidatorsToken = new GovValidatorsToken(name, symbol);

        internalProposalSettings.duration = duration;
        internalProposalSettings.quorum = quorum;

        _changeBalances(balances, validators);
    }

    function createInternalProposal(
        ProposalType proposalType,
        string calldata descriptionURL,
        uint256[] calldata newValues,
        address[] calldata users
    ) external override onlyValidator {
        if (proposalType == ProposalType.ChangeInternalDuration) {
            require(newValues[0] > 0, "Validators: invalid duration value");
        } else if (proposalType == ProposalType.ChangeInternalQuorum) {
            require(newValues[0] <= PERCENTAGE_100, "Validators: invalid quorum value");
        } else if (proposalType == ProposalType.ChangeInternalDurationAndQuorum) {
            require(
                newValues[0] > 0 && newValues[1] <= PERCENTAGE_100,
                "Validators: invalid duration or quorum values"
            );
        } else {
            require(newValues.length == users.length, "Validators: invalid length");

            for (uint256 i = 0; i < users.length; i++) {
                require(users[i] != address(0), "Validators: invalid address");
            }
        }

        _internalProposals[++latestInternalProposalId] = InternalProposal({
            proposalType: proposalType,
            core: ProposalCore({
                voteEnd: uint64(block.timestamp + internalProposalSettings.duration),
                executed: false,
                quorum: internalProposalSettings.quorum,
                votesFor: 0,
                snapshotId: govValidatorsToken.snapshot()
            }),
            descriptionURL: descriptionURL,
            newValues: newValues,
            userAddresses: users
        });

        emit InternalProposalCreated(
            latestInternalProposalId,
            descriptionURL,
            internalProposalSettings.quorum,
            msg.sender
        );
    }

    function createExternalProposal(
        uint256 proposalId,
        uint64 duration,
        uint128 quorum
    ) external override onlyOwner {
        require(!_proposalExists(proposalId, false), "Validators: proposal already exists");

        _externalProposals[proposalId] = ExternalProposal({
            core: ProposalCore({
                voteEnd: uint64(block.timestamp + duration),
                executed: false,
                quorum: quorum,
                votesFor: 0,
                snapshotId: govValidatorsToken.snapshot()
            })
        });

        emit ExternalProposalCreated(proposalId, quorum);
    }

    function changeBalances(
        uint256[] calldata newValues,
        address[] calldata userAddresses
    ) external override onlyOwner {
        _changeBalances(newValues, userAddresses);
    }

    function vote(
        uint256 proposalId,
        uint256 amount,
        bool isInternal
    ) external override onlyValidator {
        require(_proposalExists(proposalId, isInternal), "Validators: proposal does not exist");

        ProposalCore storage core = isInternal
            ? _internalProposals[proposalId].core
            : _externalProposals[proposalId].core;

        require(_getProposalState(core) == ProposalState.Voting, "Validators: not Voting state");

        uint256 balanceAt = govValidatorsToken.balanceOfAt(msg.sender, core.snapshotId);
        uint256 voted = addressVoted[proposalId][isInternal][msg.sender];

        require(amount + voted <= balanceAt, "Validators: excessive vote amount");

        addressVoted[proposalId][isInternal][msg.sender] += amount;

        core.votesFor += amount;

        emit Voted(proposalId, msg.sender, amount, isInternal);
    }

    function execute(uint256 proposalId) external override {
        require(_proposalExists(proposalId, true), "Validators: proposal does not exist");

        InternalProposal storage proposal = _internalProposals[proposalId];

        require(
            _getProposalState(proposal.core) == ProposalState.Succeeded,
            "Validators: not Succeeded state"
        );

        proposal.core.executed = true;

        ProposalType proposalType = proposal.proposalType;

        if (proposalType == ProposalType.ChangeInternalDuration) {
            internalProposalSettings.duration = uint64(proposal.newValues[0]);
        } else if (proposalType == ProposalType.ChangeInternalQuorum) {
            internalProposalSettings.quorum = uint128(proposal.newValues[0]);
        } else if (proposalType == ProposalType.ChangeInternalDurationAndQuorum) {
            internalProposalSettings.duration = uint64(proposal.newValues[0]);
            internalProposalSettings.quorum = uint128(proposal.newValues[1]);
        } else {
            _changeBalances(proposal.newValues, proposal.userAddresses);
        }

        emit InternalProposalExecuted(proposalId, msg.sender);
    }

    function getExternalProposal(
        uint256 index
    ) external view override returns (ExternalProposal memory) {
        return _externalProposals[index];
    }

    function getInternalProposals(
        uint256 offset,
        uint256 limit
    ) external view override returns (InternalProposalView[] memory internalProposals) {
        uint256 to = (offset + limit).min(latestInternalProposalId).max(offset);

        internalProposals = new InternalProposalView[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            internalProposals[i - offset] = InternalProposalView({
                proposal: _internalProposals[i + 1],
                proposalState: getProposalState(i + 1, true),
                requiredQuorum: getProposalRequiredQuorum(i + 1, true)
            });
        }
    }

    function getProposalState(
        uint256 proposalId,
        bool isInternal
    ) public view override returns (ProposalState) {
        if (!_proposalExists(proposalId, isInternal)) {
            return ProposalState.Undefined;
        }

        return
            isInternal
                ? _getProposalState(_internalProposals[proposalId].core)
                : _getProposalState(_externalProposals[proposalId].core);
    }

    function getProposalRequiredQuorum(
        uint256 proposalId,
        bool isInternal
    ) public view override returns (uint256) {
        ProposalCore storage core = isInternal
            ? _internalProposals[proposalId].core
            : _externalProposals[proposalId].core;

        if (core.voteEnd == 0) {
            return 0;
        }

        return
            govValidatorsToken.totalSupplyAt(core.snapshotId).ratio(core.quorum, PERCENTAGE_100);
    }

    function isValidator(address user) public view override returns (bool) {
        return govValidatorsToken.balanceOf(user) > 0;
    }

    function _getProposalState(ProposalCore storage core) internal view returns (ProposalState) {
        if (core.executed) {
            return ProposalState.Executed;
        }

        if (_isQuorumReached(core)) {
            return ProposalState.Succeeded;
        }

        if (core.voteEnd < block.timestamp) {
            return ProposalState.Defeated;
        }

        return ProposalState.Voting;
    }

    function _isQuorumReached(ProposalCore storage core) internal view returns (bool) {
        uint256 totalSupply = govValidatorsToken.totalSupplyAt(core.snapshotId);
        uint256 currentQuorum = PERCENTAGE_100.ratio(core.votesFor, totalSupply);

        return currentQuorum >= core.quorum;
    }

    function _proposalExists(uint256 proposalId, bool isInternal) internal view returns (bool) {
        return
            isInternal
                ? _internalProposals[proposalId].core.voteEnd != 0
                : _externalProposals[proposalId].core.voteEnd != 0;
    }

    function _changeBalances(uint256[] memory newValues, address[] memory userAddresses) internal {
        GovValidatorsToken validatorsToken = govValidatorsToken;
        uint256 length = newValues.length;

        uint256 validatorsCount_ = validatorsCount;

        for (uint256 i = 0; i < length; i++) {
            address user = userAddresses[i];
            uint256 newBalance = newValues[i];
            uint256 balance = validatorsToken.balanceOf(user);

            if (balance < newBalance) {
                validatorsToken.mint(user, newBalance - balance);

                if (balance == 0) {
                    validatorsCount_++;
                }
            } else if (balance > newBalance) {
                validatorsToken.burn(user, balance - newBalance);

                if (newBalance == 0) {
                    validatorsCount_--;
                }
            }
        }

        validatorsCount = validatorsCount_;

        emit ChangedValidatorsBalances(userAddresses, newValues);
    }

    function _onlyValidator() internal view {
        require(isValidator(msg.sender), "Validators: caller is not the validator");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

import "../../interfaces/gov/validators/IGovValidatorsToken.sol";

contract GovValidatorsToken is IGovValidatorsToken, ERC20Snapshot {
    address public immutable validator;

    modifier onlyValidator() {
        _onlyValidator();
        _;
    }

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        validator = msg.sender;
    }

    function mint(address account, uint256 amount) external override onlyValidator {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external override onlyValidator {
        _burn(account, amount);
    }

    function snapshot() external override onlyValidator returns (uint256) {
        return _snapshot();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override onlyValidator {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _onlyValidator() internal view {
        require(validator == msg.sender, "ValidatorsToken: caller is not the validator");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";
import "@dlsl/dev-modules/libs/data-structures/StringSet.sol";
import "@dlsl/dev-modules/libs/arrays/Paginator.sol";

import "../interfaces/insurance/IInsurance.sol";
import "../interfaces/factory/IPoolRegistry.sol";
import "../interfaces/core/ICoreProperties.sol";
import "../interfaces/core/IContractsRegistry.sol";

import "../libs/math/MathHelper.sol";
import "../libs/utils/TokenBalance.sol";

import "../core/Globals.sol";

contract Insurance is IInsurance, OwnableUpgradeable, AbstractDependant {
    using StringSet for StringSet.Set;
    using Paginator for StringSet.Set;
    using Math for uint256;
    using MathHelper for uint256;
    using TokenBalance for address;

    ERC20 internal _dexe;
    ICoreProperties internal _coreProperties;

    uint256 internal _poolReserved;

    mapping(address => UserInfo) public userInfos;
    mapping(string => AcceptedClaims) internal _acceptedClaimsInfo;

    StringSet.Set internal _acceptedClaims;

    event Deposited(uint256 amount, address investor);
    event Withdrawn(uint256 amount, address investor);
    event Paidout(uint256 insurancePayout, uint256 userStakePayout, address investor);

    function __Insurance_init() external initializer {
        __Ownable_init();
    }

    function setDependencies(address contractsRegistry) external override dependant {
        IContractsRegistry registry = IContractsRegistry(contractsRegistry);

        _dexe = ERC20(registry.getDEXEContract());
        _coreProperties = ICoreProperties(registry.getCorePropertiesContract());
    }

    function buyInsurance(uint256 deposit) external override {
        require(
            deposit >= _coreProperties.getMinInsuranceDeposit(),
            "Insurance: deposit is less than min"
        );

        _poolReserved += deposit;

        userInfos[msg.sender].stake += deposit;
        userInfos[msg.sender].lastDepositTimestamp = block.timestamp;

        _dexe.transferFrom(msg.sender, address(this), deposit);

        emit Deposited(deposit, msg.sender);
    }

    function withdraw(uint256 amountToWithdraw) external override {
        UserInfo storage userInfo = userInfos[msg.sender];

        require(
            userInfo.lastDepositTimestamp + _coreProperties.getInsuranceWithdrawalLock() <
                block.timestamp,
            "Insurance: lock is not over"
        );
        require(userInfo.stake >= amountToWithdraw, "Insurance: out of available amount");

        _poolReserved -= amountToWithdraw;

        userInfo.stake -= amountToWithdraw;

        _dexe.transfer(msg.sender, amountToWithdraw);

        emit Withdrawn(amountToWithdraw, msg.sender);
    }

    function acceptClaim(
        string calldata url,
        address[] calldata users,
        uint256[] memory amounts
    ) external override onlyOwner {
        require(!_acceptedClaims.contains(url), "Insurance: claim already accepted");
        require(users.length == amounts.length, "Insurance: length mismatch");

        uint256 insuranceToPay;

        for (uint256 i = 0; i < amounts.length; i++) {
            insuranceToPay += amounts[i];
        }

        uint256 accessiblePool = getMaxTreasuryPayout();

        for (uint256 i = 0; i < amounts.length; i++) {
            if (insuranceToPay >= accessiblePool) {
                amounts[i] = amounts[i].ratio(accessiblePool, insuranceToPay);
            }

            amounts[i] = _payout(users[i], amounts[i]);
        }

        _acceptedClaims.add(url);
        _acceptedClaimsInfo[url] = AcceptedClaims(users, amounts);
    }

    function getReceivedInsurance(uint256 deposit) public view override returns (uint256) {
        return deposit * _coreProperties.getInsuranceFactor();
    }

    function getInsurance(address user) external view override returns (uint256, uint256) {
        uint256 deposit = userInfos[user].stake;

        return (deposit, getReceivedInsurance(deposit));
    }

    function getMaxTreasuryPayout() public view override returns (uint256) {
        return
            (address(_dexe).thisBalance() - _poolReserved).percentage(
                _coreProperties.getMaxInsurancePoolShare()
            );
    }

    function acceptedClaimsCount() external view override returns (uint256) {
        return _acceptedClaims.length();
    }

    function listAcceptedClaims(
        uint256 offset,
        uint256 limit
    ) external view override returns (string[] memory urls, AcceptedClaims[] memory info) {
        urls = _acceptedClaims.part(offset, limit);

        info = new AcceptedClaims[](urls.length);

        for (uint256 i = 0; i < urls.length; i++) {
            info[i] = _acceptedClaimsInfo[urls[i]];
        }
    }

    function _payout(address user, uint256 insurancePayout) internal returns (uint256 payout) {
        UserInfo storage userInfo = userInfos[user];

        uint256 stakePayout = (insurancePayout / _coreProperties.getInsuranceFactor()).min(
            userInfo.stake
        );
        payout = stakePayout + insurancePayout;

        _poolReserved -= stakePayout;

        userInfo.stake -= stakePayout;

        _dexe.transfer(user, payout);

        emit Paidout(payout, stakePayout, user);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the registry contract of DEXE platform that stores information about
 * the other contracts used by the protocol. Its purpose is to keep track of the propotol's
 * contracts, provide upgradeability mechanism and dependency injection mechanism.
 */
interface IContractsRegistry {
    /// @notice Used in dependency injection mechanism
    /// @return UserRegistry contract address
    function getUserRegistryContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return PoolFactory contract address
    function getPoolFactoryContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return PoolRegistry contract address
    function getPoolRegistryContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return DEXE token contract address
    function getDEXEContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return Platform's native USD token contract address. This may be USDT/BUSD/USDC/DAI/FEI
    function getUSDContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return PriceFeed contract address
    function getPriceFeedContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return UniswapV2Router contract address. This can be any forked contract as well
    function getUniswapV2RouterContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return UniswapV2Factory contract address. This can be any forked contract as well
    function getUniswapV2FactoryContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return Insurance contract address
    function getInsuranceContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return Treasury contract/wallet address
    function getTreasuryContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return Dividends contract/wallet address
    function getDividendsContract() external view returns (address);

    /// @notice Used in dependency injection mechanism
    /// @return CoreProperties contract address
    function getCorePropertiesContract() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the central contract of the protocol which stores the parameters that may be modified by the DAO.
 * These are commissions percentages, trader leverage formula parameters, insurance parameters and pools parameters
 */
interface ICoreProperties {
    /// @notice 3 types of commission periods
    enum CommissionPeriod {
        PERIOD_1,
        PERIOD_2,
        PERIOD_3
    }

    /// @notice 3 commission receivers
    enum CommissionTypes {
        INSURANCE,
        TREASURY,
        DIVIDENDS
    }

    /// @notice The struct that stores TraderPools parameters
    /// @param maxPoolInvestors the maximum number of investors in the TraderPool
    /// @param maxOpenPositions the maximum number of concurrently opened positions by a trader
    /// @param leverageThreshold the first parameter in the trader's formula
    /// @param leverageSlope the second parameters in the trader's formula
    /// @param commissionInitTimestamp the initial timestamp of the commission rounds
    /// @param commissionDurations the durations of the commission periods in seconds - see enum CommissionPeriod
    /// @param dexeCommissionPercentage the protocol's commission percentage, multiplied by 10**25
    /// @param dexeCommissionDistributionPercentages the individual percentages of the commission contracts (should sum up to 10**27 = 100%)
    /// @param minTraderCommission the minimal trader's commission the trader can specify
    /// @param maxTraderCommissions the maximal trader's commission the trader can specify based on the chosen commission period
    /// @param delayForRiskyPool the investment delay after the first exchange in the risky pool in seconds
    struct TraderParameters {
        uint256 maxPoolInvestors;
        uint256 maxOpenPositions;
        uint256 leverageThreshold;
        uint256 leverageSlope;
        uint256 commissionInitTimestamp;
        uint256[] commissionDurations;
        uint256 dexeCommissionPercentage;
        uint256[] dexeCommissionDistributionPercentages;
        uint256 minTraderCommission;
        uint256[] maxTraderCommissions;
        uint256 delayForRiskyPool;
    }

    /// @notice The struct that stores Insurance parameters
    /// @param insuranceFactor the deposit insurance multiplier. Means how many insurance tokens is received per deposited token
    /// @param maxInsurancePoolShare the maximal share of the pool which can be used to pay out the insurance. 3 = 1/3 of the pool
    /// @param minInsuranceDeposit the minimal required deposit in DEXE tokens to receive an insurance
    /// @param insuranceWithdrawalLock the time needed to wait to withdraw tokens from the insurance after the deposit
    struct InsuranceParameters {
        uint256 insuranceFactor;
        uint256 maxInsurancePoolShare;
        uint256 minInsuranceDeposit;
        uint256 insuranceWithdrawalLock;
    }

    /// @notice The struct that stores GovPool parameters
    /// @param govVotesLimit the maximum number of simultaneous votes of the voter
    /// @param govCommission the protocol's commission percentage
    struct GovParameters {
        uint256 govVotesLimit;
        uint256 govCommissionPercentage;
    }

    /// @notice The struct that stores vital platform's parameters that may be modified by the OWNER
    struct CoreParameters {
        TraderParameters traderParams;
        InsuranceParameters insuranceParams;
        GovParameters govParams;
    }

    /// @notice The function to set CoreParameters
    /// @param _coreParameters the parameters
    function setCoreParameters(CoreParameters calldata _coreParameters) external;

    /// @notice This function adds new tokens that will be made available for the BaseTraderPool trading
    /// @param tokens the array of tokens to be whitelisted
    function addWhitelistTokens(address[] calldata tokens) external;

    /// @notice This function removes tokens from the whitelist, disabling BasicTraderPool trading of these tokens
    /// @param tokens basetokens to be removed
    function removeWhitelistTokens(address[] calldata tokens) external;

    /// @notice This function adds tokens to the blacklist, automatically updating pools positions and disabling
    /// all of the pools of trading these tokens. DAO might permanently ban malicious tokens this way
    /// @param tokens the tokens to be added to the blacklist
    function addBlacklistTokens(address[] calldata tokens) external;

    /// @notice The function that removes tokens from the blacklist, automatically updating pools positions
    /// and enabling trading of these tokens
    /// @param tokens the tokens to be removed from the blacklist
    function removeBlacklistTokens(address[] calldata tokens) external;

    /// @notice The function to set the maximum pool investors
    /// @param count new maximum pool investors
    function setMaximumPoolInvestors(uint256 count) external;

    /// @notice The function to set the maximum concurrent pool positions
    /// @param count new maximum pool positions
    function setMaximumOpenPositions(uint256 count) external;

    /// @notice The function the adjust trader leverage formula
    /// @param threshold new first parameter of the leverage function
    /// @param slope new second parameter of the leverage formula
    function setTraderLeverageParams(uint256 threshold, uint256 slope) external;

    /// @notice The function to set new initial timestamp of the commission rounds
    /// @param timestamp new timestamp (in seconds)
    function setCommissionInitTimestamp(uint256 timestamp) external;

    /// @notice The function to change the commission durations for the commission periods
    /// @param durations the array of new durations (in seconds)
    function setCommissionDurations(uint256[] calldata durations) external;

    /// @notice The function to modify the platform's commission percentages
    /// @param dexeCommission DEXE percentage commission. Should be multiplied by 10**25
    /// @param govCommission the gov percentage commission. Should be multiplied by 10**25
    /// @param distributionPercentages the percentages of the individual contracts (has to add up to 10**27)
    function setDEXECommissionPercentages(
        uint256 dexeCommission,
        uint256 govCommission,
        uint256[] calldata distributionPercentages
    ) external;

    /// @notice The function to set new bounds for the trader commission
    /// @param minTraderCommission the lower bound of the trade's commission
    /// @param maxTraderCommissions the array of upper bound commissions per period
    function setTraderCommissionPercentages(
        uint256 minTraderCommission,
        uint256[] calldata maxTraderCommissions
    ) external;

    /// @notice The function to set new investment delay for the risky pool
    /// @param delayForRiskyPool new investment delay after the first exchange
    function setDelayForRiskyPool(uint256 delayForRiskyPool) external;

    /// @notice The function to set new insurance parameters
    /// @param insuranceParams the insurance parameters
    function setInsuranceParameters(InsuranceParameters calldata insuranceParams) external;

    /// @notice The function to set new gov votes limit
    /// @param newVotesLimit new gov votes limit
    function setGovVotesLimit(uint256 newVotesLimit) external;

    /// @notice The function that returns the total number of whitelisted tokens
    /// @return the number of whitelisted tokens
    function totalWhitelistTokens() external view returns (uint256);

    /// @notice The function that returns the total number of blacklisted tokens
    /// @return the number of blacklisted tokens
    function totalBlacklistTokens() external view returns (uint256);

    /// @notice The paginated function to get addresses of whitelisted tokens
    /// @param offset the starting index of the tokens array
    /// @param limit the length of the array to observe
    /// @return tokens requested whitelist array
    function getWhitelistTokens(
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory tokens);

    /// @notice The paginated function to get addresses of blacklisted tokens
    /// @param offset the starting index of the tokens array
    /// @param limit the length of the array to observe
    /// @return tokens requested blacklist array
    function getBlacklistTokens(
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory tokens);

    /// @notice This function checks if the provided token can be opened in the BasicTraderPool
    /// @param token the token to be checked
    /// @return true if the token can be traded as the position, false otherwise
    function isWhitelistedToken(address token) external view returns (bool);

    /// @notice This function checks if the provided token is blacklisted
    /// @param token the token to be checked
    /// @return true if the token is blacklisted, false otherwise
    function isBlacklistedToken(address token) external view returns (bool);

    /// @notice The helper function that filters the provided positions tokens according to the blacklist
    /// @param positions the addresses of tokens
    /// @return filteredPositions the array of tokens without the ones in the blacklist
    function getFilteredPositions(
        address[] memory positions
    ) external view returns (address[] memory filteredPositions);

    /// @notice The function to fetch the maximum pool investors
    /// @return maximum pool investors
    function getMaximumPoolInvestors() external view returns (uint256);

    /// @notice The function to fetch the maximum concurrently opened positions
    /// @return the maximum concurrently opened positions
    function getMaximumOpenPositions() external view returns (uint256);

    /// @notice The function to get trader's leverage function parameters
    /// @return threshold the first function parameter
    /// @return slope the second function parameter
    function getTraderLeverageParams() external view returns (uint256 threshold, uint256 slope);

    /// @notice The function to get the initial commission timestamp
    /// @return the initial timestamp
    function getCommissionInitTimestamp() external view returns (uint256);

    /// @notice The function the get the commission duration for the specified period
    /// @param period the commission period
    function getCommissionDuration(CommissionPeriod period) external view returns (uint256);

    /// @notice The function to get DEXE commission percentages and receivers
    /// @return totalPercentage the overall DEXE commission percentage
    /// @return govPercentage the overall gov commission percentage
    /// @return individualPercentages the array of individual receiver's percentages
    /// individualPercentages[INSURANCE] - insurance commission
    /// individualPercentages[TREASURY] - treasury commission
    /// individualPercentages[DIVIDENDS] - dividends commission
    /// @return commissionReceivers the commission receivers
    function getDEXECommissionPercentages()
        external
        view
        returns (
            uint256 totalPercentage,
            uint256 govPercentage,
            uint256[] memory individualPercentages,
            address[3] memory commissionReceivers
        );

    /// @notice The function to get trader's commission info
    /// @return minTraderCommission minimal available trader commission
    /// @return maxTraderCommissions maximal available trader commission per period
    function getTraderCommissions()
        external
        view
        returns (uint256 minTraderCommission, uint256[] memory maxTraderCommissions);

    /// @notice The function to get the investment delay of the risky pool
    /// @return the investment delay in seconds
    function getDelayForRiskyPool() external view returns (uint256);

    /// @notice The function to get the insurance deposit multiplier
    /// @return the multiplier
    function getInsuranceFactor() external view returns (uint256);

    /// @notice The function to get the max payout share of the insurance pool
    /// @return the max pool share to be paid in a single request
    function getMaxInsurancePoolShare() external view returns (uint256);

    /// @notice The function to get the min allowed insurance deposit
    /// @return the min allowed insurance deposit in DEXE tokens
    function getMinInsuranceDeposit() external view returns (uint256);

    /// @notice The function to get insurance withdrawal lock duration
    /// @return the duration of insurance lock
    function getInsuranceWithdrawalLock() external view returns (uint256);

    /// @notice The function to get max votes limit of the gov pool
    /// @return votesLimit the votes limit
    function getGovVotesLimit() external view returns (uint256 votesLimit);

    /// @notice The function to get current commission epoch based on the timestamp and period
    /// @param timestamp the timestamp (should not be less than the initial timestamp)
    /// @param commissionPeriod the enum of commission durations
    /// @return the number of the epoch
    function getCommissionEpochByTimestamp(
        uint256 timestamp,
        CommissionPeriod commissionPeriod
    ) external view returns (uint256);

    /// @notice The funcition to get the end timestamp of the provided commission epoch
    /// @param epoch the commission epoch to get the end timestamp for
    /// @param commissionPeriod the enum of commission durations
    /// @return the end timestamp of the provided commission epoch
    function getCommissionTimestampByEpoch(
        uint256 epoch,
        CommissionPeriod commissionPeriod
    ) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the price feed contract which is used to fetch the spot prices from the UniswapV2 protocol + execute swaps
 * on its pairs. The protocol does not require price oracles to be secure and reliable. There also is a pathfinder
 * built into the contract to find the optimal* path between the pairs
 */
interface IPriceFeed {
    /// @notice A struct this is returned from the UniswapV2PathFinder library when an optimal* path is found
    /// @param path the optimal* path itself
    /// @param amounts either the "amounts out" or "amounts in" required
    /// @param withProvidedPath a bool flag saying if the path is found via the specified path
    struct FoundPath {
        address[] path;
        uint256[] amounts;
        bool withProvidedPath;
    }

    /// @notice This function sets path tokens that will be used in the pathfinder
    /// @param pathTokens the array of tokens to be added into the path finder
    function addPathTokens(address[] calldata pathTokens) external;

    /// @notice This function removes path tokens from the pathfinder
    /// @param pathTokens the array of tokens to be removed from the pathfinder
    function removePathTokens(address[] calldata pathTokens) external;

    /// @notice The function that performs an actual Uniswap swap (swapExactTokensForTokens),
    /// taking the amountIn inToken tokens from the msg.sender and sending not less than minAmountOut outTokens back.
    /// The approval of amountIn tokens has to be made to this address beforehand
    /// @param inToken the token to be exchanged from
    /// @param outToken the token to be exchanged to
    /// @param amountIn the amount of inToken tokens to be exchanged
    /// @param optionalPath the optional path that will be considered by the pathfinder to find the best route
    /// @param minAmountOut the minimal amount of outToken tokens that have to be received after the swap.
    /// basically this is a sandwich attack protection mechanism
    /// @return the amount of outToken tokens sent to the msg.sender after the swap
    function exchangeFromExact(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] calldata optionalPath,
        uint256 minAmountOut
    ) external returns (uint256);

    /// @notice The function that performs an actual Uniswap swap (swapTokensForExactTokens),
    /// taking not more than maxAmountIn inToken tokens from the msg.sender and sending amountOut outTokens back.
    /// The approval of maxAmountIn tokens has to be made to this address beforehand
    /// @param inToken the token to be exchanged from
    /// @param outToken the token to be exchanged to
    /// @param amountOut the amount of outToken tokens to be received
    /// @param optionalPath the optional path that will be considered by the pathfinder to find the best route
    /// @param maxAmountIn the maximal amount of inTokens that have to be taken to execute the swap.
    /// basically this is a sandwich attack protection mechanism
    /// @return the amount of inTokens taken from the msg.sender
    function exchangeToExact(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] calldata optionalPath,
        uint256 maxAmountIn
    ) external returns (uint256);

    /// @notice The same as "exchangeFromExact" except that the amount of inTokens and received amount of outTokens is normalized
    /// @param inToken the token to be exchanged from
    /// @param outToken the token to be exchanged to
    /// @param amountIn the amount of inTokens to be exchanged (in 18 decimals)
    /// @param optionalPath the optional path that will be considered by the pathfinder
    /// @param minAmountOut the minimal amount of outTokens to be received (also normalized)
    /// @return normalized amount of outTokens sent to the msg.sender after the swap
    function normalizedExchangeFromExact(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] calldata optionalPath,
        uint256 minAmountOut
    ) external returns (uint256);

    /// @notice The same as "exchangeToExact" except that the amount of inTokens and received amount of outTokens is normalized
    /// @param inToken the token to be exchanged from
    /// @param outToken the token to be exchanged to
    /// @param amountOut the amount of outTokens to be received (in 18 decimals)
    /// @param optionalPath the optional path that will be considered by the pathfinder
    /// @param maxAmountIn the maximal amount of inTokens to be taken (also normalized)
    /// @return normalized amount of inTokens taken from the msg.sender to execute the swap
    function normalizedExchangeToExact(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] calldata optionalPath,
        uint256 maxAmountIn
    ) external returns (uint256);

    /// @notice This function tries to find the optimal exchange rate (the price) between "inToken" and "outToken" using
    /// custom pathfinder, saved paths and optional specified path. The optimality is reached when the amount of
    /// outTokens is maximal
    /// @param inToken the token to exchange from
    /// @param outToken the received token
    /// @param amountIn the amount of inToken to be exchanged (in inToken decimals)
    /// @param optionalPath the optional path between inToken and outToken that will be used in the pathfinder
    /// @return amountOut amount of outToken after the swap (in outToken decimals)
    /// @return path the tokens path that will be used during the swap
    function getExtendedPriceOut(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] memory optionalPath
    ) external view returns (uint256 amountOut, address[] memory path);

    /// @notice This function tries to find the optimal exchange rate (the price) between "inToken" and "outToken" using
    /// custom pathfinder, saved paths and optional specified path. The optimality is reached when the amount of
    /// inTokens is minimal
    /// @param inToken the token to exchange from
    /// @param outToken the received token
    /// @param amountOut the amount of outToken to be received (in inToken decimals)
    /// @param optionalPath the optional path between inToken and outToken that will be used in the pathfinder
    /// @return amountIn amount of inToken to execute a swap (in outToken decimals)
    /// @return path the tokens path that will be used during the swap
    function getExtendedPriceIn(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] memory optionalPath
    ) external view returns (uint256 amountIn, address[] memory path);

    /// @notice Shares the same functionality as "getExtendedPriceOut" function with automatic usage of saved paths.
    /// It accepts and returns amounts with 18 decimals regardless of the inToken and outToken decimals
    /// @param inToken the token to exchange from
    /// @param outToken the token to exchange to
    /// @param amountIn the amount of inToken to be exchanged (with 18 decimals)
    /// @return amountOut the received amount of outToken after the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedPriceOut(
        address inToken,
        address outToken,
        uint256 amountIn
    ) external view returns (uint256 amountOut, address[] memory path);

    /// @notice Shares the same functionality as "getExtendedPriceIn" function with automatic usage of saved paths.
    /// It accepts and returns amounts with 18 decimals regardless of the inToken and outToken decimals
    /// @param inToken the token to exchange from
    /// @param outToken the token to exchange to
    /// @param amountOut the amount of outToken to be received (with 18 decimals)
    /// @return amountIn required amount of inToken to execute the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedPriceIn(
        address inToken,
        address outToken,
        uint256 amountOut
    ) external view returns (uint256 amountIn, address[] memory path);

    /// @notice Shares the same functionality as "getExtendedPriceOut" function.
    /// It accepts and returns amounts with 18 decimals regardless of the inToken and outToken decimals
    /// @param inToken the token to exchange from
    /// @param outToken the token to exchange to
    /// @param amountIn the amount of inToken to be exchanged (with 18 decimals)
    /// @param optionalPath the optional path between inToken and outToken that will be used in the pathfinder
    /// @return amountOut the received amount of outToken after the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedExtendedPriceOut(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] memory optionalPath
    ) external view returns (uint256 amountOut, address[] memory path);

    /// @notice Shares the same functionality as "getExtendedPriceIn" function.
    /// It accepts and returns amounts with 18 decimals regardless of the inToken and outToken decimals
    /// @param inToken the token to exchange from
    /// @param outToken the token to exchange to
    /// @param amountOut the amount of outToken to be received (with 18 decimals)
    /// @param optionalPath the optional path between inToken and outToken that will be used in the pathfinder
    /// @return amountIn the required amount of inToken to execute the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedExtendedPriceIn(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] memory optionalPath
    ) external view returns (uint256 amountIn, address[] memory path);

    /// @notice The same as "getPriceOut" with "outToken" being native USD token
    /// @param inToken the token to be exchanged from
    /// @param amountIn the amount of inToken to exchange (with 18 decimals)
    /// @return amountOut the received amount of native USD tokens after the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedPriceOutUSD(
        address inToken,
        uint256 amountIn
    ) external view returns (uint256 amountOut, address[] memory path);

    /// @notice The same as "getPriceIn" with "outToken" being USD token
    /// @param inToken the token to get the price of
    /// @param amountOut the amount of USD to be received (with 18 decimals)
    /// @return amountIn the required amount of inToken to execute the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedPriceInUSD(
        address inToken,
        uint256 amountOut
    ) external view returns (uint256 amountIn, address[] memory path);

    /// @notice The same as "getPriceOut" with "outToken" being DEXE token
    /// @param inToken the token to be exchanged from
    /// @param amountIn the amount of inToken to exchange (with 18 decimals)
    /// @return amountOut the received amount of DEXE tokens after the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedPriceOutDEXE(
        address inToken,
        uint256 amountIn
    ) external view returns (uint256 amountOut, address[] memory path);

    /// @notice The same as "getPriceIn" with "outToken" being DEXE token
    /// @param inToken the token to get the price of
    /// @param amountOut the amount of DEXE to be received (with 18 decimals)
    /// @return amountIn the required amount of inToken to execute the swap (with 18 decimals)
    /// @return path the tokens path that will be used during the swap
    function getNormalizedPriceInDEXE(
        address inToken,
        uint256 amountOut
    ) external view returns (uint256 amountIn, address[] memory path);

    /// @notice The function that returns the total number of path tokens (tokens used in the pathfinder)
    /// @return the number of path tokens
    function totalPathTokens() external view returns (uint256);

    /// @notice The function to get the list of path tokens
    /// @return the list of path tokens
    function getPathTokens() external view returns (address[] memory);

    /// @notice The function to get the list of saved tokens of the pool
    /// @param pool the address the path is saved for
    /// @param from the from token (path beginning)
    /// @param to the to token (path ending)
    /// @return the array of addresses representing the inclusive path between tokens
    function getSavedPaths(
        address pool,
        address from,
        address to
    ) external view returns (address[] memory);

    /// @notice This function checks if the provided token is used by the pathfinder
    /// @param token the token to be checked
    /// @return true if the token is used by the pathfinder, false otherwise
    function isSupportedPathToken(address token) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../gov/settings/IGovSettings.sol";
import "../core/ICoreProperties.sol";

/**
 * This is the Factory contract for the trader and gov pools. Anyone can create a pool for themselves to become a trader
 * or a governance owner. There are 3 pools available: BasicTraderPool, InvestTraderPool and GovPool
 */
interface IPoolFactory {
    struct SettingsDeployParams {
        IGovSettings.ProposalSettings[] proposalSettings;
        address[] additionalProposalExecutors;
    }

    struct ValidatorsDeployParams {
        string name;
        string symbol;
        uint64 duration;
        uint128 quorum;
        address[] validators;
        uint256[] balances;
    }

    struct UserKeeperDeployParams {
        address tokenAddress;
        address nftAddress;
        uint256 totalPowerInTokens;
        uint256 nftsTotalSupply;
    }

    struct GovPoolDeployParams {
        SettingsDeployParams settingsParams;
        ValidatorsDeployParams validatorsParams;
        UserKeeperDeployParams userKeeperParams;
        address nftMultiplierAddress;
        string descriptionURL;
        string name;
    }

    /// @notice The parameters one can specify on the trader pool's creation
    /// @param descriptionURL the IPFS URL of the pool description
    /// @param trader the trader of the pool
    /// @param privatePool the publicity of the pool
    /// @param totalLPEmission maximal* emission of LP tokens that can be invested
    /// @param baseToken the address of the base token of the pool
    /// @param minimalInvestment the minimal allowed investment into the pool
    /// @param commissionPeriod the duration of the commission period
    /// @param commissionPercentage trader's commission percentage (including DEXE commission)
    struct TraderPoolDeployParameters {
        string descriptionURL;
        address trader;
        bool privatePool;
        uint256 totalLPEmission; // zero means unlimited
        address baseToken;
        uint256 minimalInvestment; // zero means any value
        ICoreProperties.CommissionPeriod commissionPeriod;
        uint256 commissionPercentage;
    }

    /// @notice The function to deploy gov pools
    /// @param parameters the pool deploy parameters
    function deployGovPool(GovPoolDeployParams calldata parameters) external;

    /// @notice The function to deploy basic pools
    /// @param name the ERC20 name of the pool
    /// @param symbol the ERC20 symbol of the pool
    /// @param parameters the pool deploy parameters
    function deployBasicPool(
        string calldata name,
        string calldata symbol,
        TraderPoolDeployParameters calldata parameters
    ) external;

    /// @notice The function to deploy invest pools
    /// @param name the ERC20 name of the pool
    /// @param symbol the ERC20 symbol of the pool
    /// @param parameters the pool deploy parameters
    function deployInvestPool(
        string calldata name,
        string calldata symbol,
        TraderPoolDeployParameters calldata parameters
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../trader/ITraderPool.sol";

/**
 * This is the PoolRegistry contract, a tuned ContractsRegistry contract. Its purpose is the management of
 * TraderPools, proposal pools, GovPools and contracts related to GovPools.
 * The owner of this contract is capable of upgrading pools' implementation via the ProxyBeacon pattern
 */
interface IPoolRegistry {
    /// @notice The function to add the pool proxy to the registry (called by the PoolFactory)
    /// @param name the type of the pool
    /// @param poolAddress the address of the pool to add
    function addProxyPool(string calldata name, address poolAddress) external;

    /// @notice The function to associate an owner with the pool (called by the PoolFactory)
    /// @param user the trader of the pool
    /// @param name the type of the pool
    /// @param poolAddress the address of the new pool
    function associateUserWithPool(
        address user,
        string calldata name,
        address poolAddress
    ) external;

    /// @notice The function that counts associated pools by their type
    /// @param user the owner of the pool
    /// @param name the type of the pool
    /// @return the total number of pools with the specified type
    function countAssociatedPools(
        address user,
        string calldata name
    ) external view returns (uint256);

    /// @notice The function that lists associated pools by the provided type and user
    /// @param user the trader
    /// @param name the type of the pool
    /// @param offset the starting index of the pools array
    /// @param limit the length of the observed pools array
    /// @return pools the addresses of the pools
    function listAssociatedPools(
        address user,
        string calldata name,
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory pools);

    /// @notice The function that lists trader pools with their static info
    /// @param name the type of the pool
    /// @param offset the the starting index of the pools array
    /// @param limit the length of the observed pools array
    /// @return pools the addresses of the pools
    /// @return poolInfos the array of static information per pool
    /// @return leverageInfos the array of trader leverage information per pool
    function listTraderPoolsWithInfo(
        string calldata name,
        uint256 offset,
        uint256 limit
    )
        external
        view
        returns (
            address[] memory pools,
            ITraderPool.PoolInfo[] memory poolInfos,
            ITraderPool.LeverageInfo[] memory leverageInfos
        );

    /// @notice The function to check if the given address is a valid BasicTraderPool
    /// @param potentialPool the address to inspect
    /// @return true if the address is a BasicTraderPool, false otherwise
    function isBasicPool(address potentialPool) external view returns (bool);

    /// @notice The function to check if the given address is a valid InvestTraderPool
    /// @param potentialPool the address to inspect
    /// @return true if the address is an InvestTraderPool, false otherwise
    function isInvestPool(address potentialPool) external view returns (bool);

    /// @notice The function to check if the given address is a valid TraderPool
    /// @param potentialPool the address to inspect
    /// @return true if the address is a TraderPool, false otherwise
    function isTraderPool(address potentialPool) external view returns (bool);

    /// @notice The function to check if the given address is a valid GovPool
    /// @param potentialPool the address to inspect
    /// @return true if the address is a GovPool, false otherwise
    function isGovPool(address potentialPool) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

interface IERC721Multiplier is IERC721Enumerable {
    struct NftInfo {
        uint256 multiplier;
        uint256 duration;
        uint256 lockedAt;
    }

    function lock(uint256 tokenId) external;

    function mint(address to, uint256 multiplier, uint256 duration) external;

    function getExtraRewards(address whose, uint256 rewards) external view returns (uint256);

    function getCurrentMultiplier(
        address whose
    ) external view returns (uint256 multiplier, uint256 timeLeft);

    function isLocked(uint256 tokenId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/**
 * This is the custom NFT contract with voting power
 */
interface IERC721Power is IERC721Enumerable {
    struct NftInfo {
        uint64 lastUpdate;
        uint256 currentPower;
        uint256 currentCollateral;
        uint256 maxPower;
        uint256 requiredCollateral;
    }

    /// @notice Get total power
    /// @return totalPower
    function totalPower() external view returns (uint256);

    /// @notice Add collateral amount to certain nft
    /// @param amount Wei
    /// @param tokenId Nft number
    function addCollateral(uint256 amount, uint256 tokenId) external;

    /// @notice Remove collateral amount from certain nft
    /// @param amount Wei
    /// @param tokenId Nft number
    function removeCollateral(uint256 amount, uint256 tokenId) external;

    /// @notice Recalculate nft power (coefficient)
    /// @param tokenId Nft number
    /// @return new Nft power
    function recalculateNftPower(uint256 tokenId) external returns (uint256);

    /// @notice Return max possible power (coefficient) for nft
    /// @param tokenId Nft number
    /// @return max power for Nft
    function getMaxPowerForNft(uint256 tokenId) external view returns (uint256);

    /// @notice Return required collateral amount for nft
    /// @param tokenId Nft number
    /// @return required collateral for Nft
    function getRequiredCollateralForNft(uint256 tokenId) external view returns (uint256);

    /// @notice The function to get current NFT power
    /// @param tokenId the Nft number
    /// @return current power of the Nft
    function getNftPower(uint256 tokenId) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../../libs/data-structures/ShrinkableArray.sol";

import "./settings/IGovSettings.sol";
import "./validators/IGovValidators.sol";

/**
 * This is the Governance pool contract. This contract is the third contract the user can deploy through
 * the factory. The users can participate in proposal's creation, voting and execution processes
 */
interface IGovPool {
    enum ProposalState {
        Voting,
        WaitingForVotingTransfer,
        ValidatorVoting,
        Defeated,
        Succeeded,
        Executed,
        Undefined
    }

    struct ProposalCore {
        IGovSettings.ProposalSettings settings;
        bool executed;
        uint64 voteEnd;
        uint256 votesFor;
        uint256 nftPowerSnapshotId;
    }

    struct Proposal {
        ProposalCore core;
        string descriptionURL;
        address[] executors;
        uint256[] values;
        bytes[] data;
    }

    struct ProposalView {
        Proposal proposal;
        IGovValidators.ExternalProposal validatorProposal;
        ProposalState proposalState;
        uint256 requiredQuorum;
        uint256 requiredValidatorsQuorum;
    }

    struct VoteInfo {
        uint256 totalVoted;
        uint256 tokensVoted;
        EnumerableSet.UintSet nftsVoted;
    }

    struct VoteInfoView {
        uint256 totalVoted;
        uint256 tokensVoted;
        uint256[] nftsVoted;
    }

    function nftMultiplier() external view returns (address);

    function latestProposalId() external view returns (uint256);

    /// @notice The function to get helper contract of this pool
    /// @return settings settings address
    /// @return userKeeper user keeper address
    /// @return validators validators address
    /// @return distributionProposal distribution proposal address
    function getHelperContracts()
        external
        view
        returns (
            address settings,
            address userKeeper,
            address validators,
            address distributionProposal
        );

    /// @notice Create proposal
    /// @notice For internal proposal, last executor should be `GovSetting` contract
    /// @notice For typed proposal, last executor should be typed contract
    /// @notice For external proposal, any configuration of addresses and bytes
    /// @param descriptionURL IPFS url to the proposal's description
    /// @param executors Executors addresses
    /// @param values the ether values
    /// @param data data Bytes
    function createProposal(
        string calldata descriptionURL,
        string calldata misc,
        address[] memory executors,
        uint256[] calldata values,
        bytes[] calldata data
    ) external;

    /// @notice Move proposal from internal voting to `Validators` contract
    /// @param proposalId Proposal ID
    function moveProposalToValidators(uint256 proposalId) external;

    function vote(
        uint256 proposalId,
        uint256 depositAmount,
        uint256[] calldata depositNftIds,
        uint256 voteAmount,
        uint256[] calldata voteNftIds
    ) external;

    function voteDelegated(
        uint256 proposalId,
        uint256 voteAmount,
        uint256[] calldata voteNftIds
    ) external;

    function deposit(address receiver, uint256 amount, uint256[] calldata nftIds) external;

    function withdraw(address receiver, uint256 amount, uint256[] calldata nftIds) external;

    function delegate(address delegatee, uint256 amount, uint256[] calldata nftIds) external;

    function undelegate(address delegatee, uint256 amount, uint256[] calldata nftIds) external;

    function unlock(address user, bool isMicropool) external;

    function unlockInProposals(
        uint256[] memory proposalIds,
        address user,
        bool isMicropool
    ) external;

    /// @notice Execute proposal
    /// @param proposalId Proposal ID
    function execute(uint256 proposalId) external;

    function claimRewards(uint256[] calldata proposalIds) external;

    function executeAndClaim(uint256 proposalId) external;

    function editDescriptionURL(string calldata newDescriptionURL) external;

    function setNftMultiplierAddress(address nftMultiplierAddress) external;

    function getProposals(
        uint256 offset,
        uint256 limit
    ) external view returns (ProposalView[] memory);

    /// @param proposalId Proposal ID
    /// @return `ProposalState`:
    /// 0 -`Voting`, proposal where addresses can vote
    /// 1 -`WaitingForVotingTransfer`, approved proposal that waiting `moveProposalToValidators()` call
    /// 2 -`ValidatorVoting`, validators voting
    /// 3 -`Defeated`, proposal where voting time is over and proposal defeated on first or second step
    /// 4 -`Succeeded`, proposal with the required number of votes on each step
    /// 5 -`Executed`, executed proposal
    /// 6 -`Undefined`, nonexistent proposal
    function getProposalState(uint256 proposalId) external view returns (ProposalState);

    function getTotalVotes(
        uint256 proposalId,
        address voter,
        bool isMicropool
    ) external view returns (uint256, uint256);

    function getProposalRequiredQuorum(uint256 proposalId) external view returns (uint256);

    function getUserVotes(
        uint256 proposalId,
        address voter,
        bool isMicropool
    ) external view returns (VoteInfoView memory);

    function getWithdrawableAssets(
        address delegator,
        address delegatee
    ) external view returns (uint256, ShrinkableArray.UintArray memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the contract the governance can execute in order to distribute rewards proportionally among
 * all the voters who participated in the certain proposal
 */
interface IDistributionProposal {
    struct DistributionProposalStruct {
        address rewardAddress;
        uint256 rewardAmount;
        mapping(address => bool) claimed;
    }

    /// @notice Executed by `Gov` contract, open 'claim'
    function execute(uint256 proposalId, address token, uint256 amount) external payable;

    /// @notice Distribute rewards
    /// @param voter Voter address
    function claim(address voter, uint256[] calldata proposalIds) external;

    /// @notice Return potential reward. If user hasn't voted, or `getTotalVotesWeight` is zero, return zero
    /// @param voter Voter address
    function getPotentialReward(
        uint256 proposalId,
        address voter,
        uint256 rewardAmount
    ) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the contract that stores proposal settings that will be used by the governance pool
 */
interface IGovSettings {
    enum ExecutorType {
        DEFAULT,
        INTERNAL,
        DISTRIBUTION,
        VALIDATORS
    }

    struct ProposalSettings {
        bool earlyCompletion;
        bool delegatedVotingAllowed;
        bool validatorsVote;
        uint64 duration;
        uint64 durationValidators;
        uint128 quorum;
        uint128 quorumValidators;
        uint256 minVotesForVoting;
        uint256 minVotesForCreating;
        address rewardToken;
        uint256 creationReward;
        uint256 executionReward;
        uint256 voteRewardsCoefficient;
        string executorDescription;
    }

    /// @notice The function to get settings of this executor
    /// @param executor the executor
    /// @return setting id of the executor
    function executorToSettings(address executor) external view returns (uint256);

    /// @notice Add new types to contract
    /// @param _settings New settings
    function addSettings(ProposalSettings[] calldata _settings) external;

    /// @notice Edit existed type
    /// @param settingsIds Existed settings IDs
    /// @param _settings New settings
    function editSettings(
        uint256[] calldata settingsIds,
        ProposalSettings[] calldata _settings
    ) external;

    /// @notice Change executors association
    /// @param executors Addresses
    /// @param settingsIds New types
    function changeExecutors(
        address[] calldata executors,
        uint256[] calldata settingsIds
    ) external;

    /// @notice The function to get default settings
    /// @return default setting
    function getDefaultSettings() external view returns (ProposalSettings memory);

    /// @notice The function the get the settings of the executor
    /// @param executor Executor address
    /// @return `ProposalSettings` by `executor` address
    function getExecutorSettings(address executor) external view returns (ProposalSettings memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../../../libs/data-structures/ShrinkableArray.sol";

/**
 * This contract is responsible for securely storing user's funds that are used during the voting. These are either
 * ERC20 tokens or NFTs
 */
interface IGovUserKeeper {
    struct BalanceInfo {
        uint256 tokenBalance;
        uint256 maxTokensLocked;
        mapping(uint256 => uint256) lockedInProposals; // proposal id => locked amount
        EnumerableSet.UintSet nftBalance; // array of NFTs
    }

    struct UserInfo {
        BalanceInfo balanceInfo;
        mapping(address => uint256) delegatedTokens; // delegatee => amount
        mapping(address => EnumerableSet.UintSet) delegatedNfts; // delegatee => tokenIds
        EnumerableSet.AddressSet delegatees;
    }

    struct NFTInfo {
        bool isSupportPower;
        uint256 totalPowerInTokens;
        uint256 totalSupply;
    }

    struct VotingPowerView {
        uint256 power;
        uint256 nftPower;
        uint256[] perNftPower;
        uint256 ownedBalance;
        uint256 ownedLength;
        uint256[] nftIds;
    }

    struct DelegationInfoView {
        address delegatee;
        uint256 delegatedTokens;
        uint256[] delegatedNfts;
        uint256 nftPower;
        uint256[] perNftPower;
    }

    function depositTokens(address payer, address receiver, uint256 amount) external;

    function withdrawTokens(address payer, address receiver, uint256 amount) external;

    function delegateTokens(address delegator, address delegatee, uint256 amount) external;

    function undelegateTokens(address delegator, address delegatee, uint256 amount) external;

    function depositNfts(address payer, address receiver, uint256[] calldata nftIds) external;

    function withdrawNfts(address payer, address receiver, uint256[] calldata nftIds) external;

    function delegateNfts(
        address delegator,
        address delegatee,
        uint256[] calldata nftIds
    ) external;

    function undelegateNfts(
        address delegator,
        address delegatee,
        uint256[] calldata nftIds
    ) external;

    function createNftPowerSnapshot() external returns (uint256);

    function updateMaxTokenLockedAmount(
        uint256[] calldata lockedProposals,
        address voter,
        bool isMicropool
    ) external;

    function lockTokens(
        uint256 proposalId,
        address voter,
        bool isMicropool,
        uint256 amount
    ) external;

    function unlockTokens(
        uint256 proposalId,
        address voter,
        bool isMicropool
    ) external returns (uint256 unlockedAmount);

    function lockNfts(
        address voter,
        bool isMicropool,
        bool useDelegated,
        uint256[] calldata nftIds
    ) external;

    function unlockNfts(uint256[] calldata nftIds) external;

    function updateNftPowers(uint256[] calldata nftIds) external;

    function setERC20Address(address _tokenAddress) external;

    function setERC721Address(
        address _nftAddress,
        uint256 totalPowerInTokens,
        uint256 nftsTotalSupply
    ) external;

    function getNftInfo() external view returns (NFTInfo memory);

    function maxLockedAmount(address voter, bool isMicropool) external view returns (uint256);

    function tokenBalance(
        address voter,
        bool isMicropool,
        bool useDelegated
    ) external view returns (uint256 balance, uint256 ownedBalance);

    function nftBalance(
        address voter,
        bool isMicropool,
        bool useDelegated
    ) external view returns (uint256 balance, uint256 ownedBalance);

    function nftExactBalance(
        address voter,
        bool isMicropool,
        bool useDelegated
    ) external view returns (uint256[] memory nfts, uint256 ownedLength);

    function getNftsPowerInTokensBySnapshot(
        uint256[] calldata nftIds,
        uint256 snapshotId
    ) external view returns (uint256);

    function getTotalVoteWeight() external view returns (uint256);

    function canParticipate(
        address voter,
        bool isMicropool,
        bool useDelegated,
        uint256 requiredVotes,
        uint256 snapshotId
    ) external view returns (bool);

    function votingPower(
        address[] calldata users,
        bool[] calldata isMicropools,
        bool[] calldata useDelegated
    ) external view returns (VotingPowerView[] memory votingPowers);

    function nftVotingPower(
        uint256[] memory nftIds
    ) external view returns (uint256 nftPower, uint256[] memory perNftPower);

    function delegations(
        address user
    ) external view returns (uint256 power, DelegationInfoView[] memory delegationsInfo);

    function getUndelegateableAssets(
        address delegator,
        address delegatee,
        ShrinkableArray.UintArray calldata lockedProposals,
        uint256[] calldata unlockedNfts
    )
        external
        view
        returns (
            uint256 undelegateableTokens,
            ShrinkableArray.UintArray memory undelegateableNfts
        );

    function getWithdrawableAssets(
        address voter,
        ShrinkableArray.UintArray calldata lockedProposals,
        uint256[] calldata unlockedNfts
    )
        external
        view
        returns (uint256 withdrawableTokens, ShrinkableArray.UintArray memory withdrawableNfts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the voting contract that is queried on the proposal's second voting stage
 */
interface IGovValidators {
    enum ProposalState {
        Voting,
        Defeated,
        Succeeded,
        Executed,
        Undefined
    }

    enum ProposalType {
        ChangeInternalDuration,
        ChangeInternalQuorum,
        ChangeInternalDurationAndQuorum,
        ChangeBalances
    }

    struct InternalProposalSettings {
        uint64 duration;
        uint128 quorum;
    }

    struct ProposalCore {
        bool executed;
        uint64 voteEnd;
        uint128 quorum;
        uint256 votesFor;
        uint256 snapshotId;
    }

    struct InternalProposal {
        ProposalType proposalType;
        ProposalCore core;
        string descriptionURL;
        uint256[] newValues;
        address[] userAddresses;
    }

    struct ExternalProposal {
        ProposalCore core;
    }

    struct InternalProposalView {
        InternalProposal proposal;
        ProposalState proposalState;
        uint256 requiredQuorum;
    }

    function latestInternalProposalId() external view returns (uint256);

    function validatorsCount() external view returns (uint256);

    /// @notice Create internal proposal for changing validators balances, base quorum, base duration
    /// @param proposalType `ProposalType`
    /// 0 - `ChangeInternalDuration`, change base duration
    /// 1 - `ChangeInternalQuorum`, change base quorum
    /// 2 - `ChangeInternalDurationAndQuorum`, change base duration and quorum
    /// 3 - `ChangeBalances`, change address balance
    /// @param newValues New values (tokens amounts array, quorum or duration or both)
    /// @param userAddresses Validators addresses, set it if `proposalType` == `ChangeBalances`
    function createInternalProposal(
        ProposalType proposalType,
        string calldata descriptionURL,
        uint256[] calldata newValues,
        address[] calldata userAddresses
    ) external;

    /// @notice Create external proposal. This function can call only `Gov` contract
    /// @param proposalId Proposal ID from `Gov` contract
    /// @param duration Duration from `Gov` contract
    /// @param quorum Quorum from `Gov` contract
    function createExternalProposal(uint256 proposalId, uint64 duration, uint128 quorum) external;

    function changeBalances(
        uint256[] calldata newValues,
        address[] calldata userAddresses
    ) external;

    /// @notice Vote in proposal
    /// @param proposalId Proposal ID, internal or external
    /// @param amount Amount of tokens to vote
    /// @param isInternal If `true`, you will vote in internal proposal
    function vote(uint256 proposalId, uint256 amount, bool isInternal) external;

    /// @notice Only for internal proposals. External proposals should be executed from governance.
    /// @param proposalId Internal proposal ID
    function execute(uint256 proposalId) external;

    function getExternalProposal(uint256 index) external view returns (ExternalProposal memory);

    function getInternalProposals(
        uint256 offset,
        uint256 limit
    ) external view returns (InternalProposalView[] memory);

    /// @notice Return proposal state
    /// @dev Options:
    /// `Voting` - proposal where addresses can vote.
    /// `Defeated` - proposal where voting time is over and proposal defeated.
    /// `Succeeded` - proposal with the required number of votes.
    /// `Executed` - executed proposal (only for internal proposal).
    /// `Undefined` - nonexistent proposal.
    function getProposalState(
        uint256 proposalId,
        bool isInternal
    ) external view returns (ProposalState);

    function getProposalRequiredQuorum(
        uint256 proposalId,
        bool isInternal
    ) external view returns (uint256);

    function isValidator(address user) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * This is the contract that determines the validators
 */
interface IGovValidatorsToken is IERC20 {
    /// @notice Mint new tokens, available only from `Validators` contract
    /// @param account Address
    /// @param amount Token amount to mint. Wei
    function mint(address account, uint256 amount) external;

    /// @notice Burn tokens, available only from `Validators` contract
    /// @param account Address
    /// @param amount Token amount to burn. Wei
    function burn(address account, uint256 amount) external;

    /// @notice Create tokens snapshot
    /// @return Snapshot ID
    function snapshot() external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the native DEXE insurance contract. Users can come and insure their invested funds by putting
 * DEXE tokens here. If the accident happens, the claim proposal has to be made for further investigation by the
 * DAO. The insurance is paid in DEXE tokens to all the provided addresses and backed by the commissions the protocol receives
 */
interface IInsurance {
    /// @notice The struct that holds accepted claims info
    /// @param claimers the addresses that received the payout
    /// @param amounts the amounts in DEXE tokens paid to the claimers
    /// @param status the final status of the claim
    struct AcceptedClaims {
        address[] claimers;
        uint256[] amounts;
    }

    /// @notice The struct that holds information about the user
    /// @param stake the amount of tokens the user staked (bought the insurance for)
    /// @param lastDepositTimestamp the timestamp of user's last deposit
    struct UserInfo {
        uint256 stake;
        uint256 lastDepositTimestamp;
    }

    /// @notice The function to buy an insurance for the deposited DEXE tokens. Minimal insurance is specified by the DAO
    /// @param deposit the amount of DEXE tokens to be deposited
    function buyInsurance(uint256 deposit) external;

    /// @notice The function to withdraw deposited DEXE tokens back (the insurance will cover less tokens as well)
    /// @param amountToWithdraw the amount of DEXE tokens to withdraw
    function withdraw(uint256 amountToWithdraw) external;

    /// @notice The function called by the DAO to accept the claim
    /// @param url the IPFS URL of the claim to accept
    /// @param users the receivers of the claim
    /// @param amounts the amounts in DEXE tokens to be paid to the receivers (the contract will validate the payout amounts)
    function acceptClaim(
        string calldata url,
        address[] calldata users,
        uint256[] memory amounts
    ) external;

    /// @notice The function that calculates received insurance from the deposited tokens
    /// @param deposit the amount of tokens to be deposited
    /// @return the received insurance tokens
    function getReceivedInsurance(uint256 deposit) external view returns (uint256);

    /// @notice The function to get user's insurance info
    /// @param user the user to get info about
    /// @return deposit the total DEXE deposit of the provided user
    /// @return insurance the total insurance of the provided user
    function getInsurance(address user) external view returns (uint256 deposit, uint256 insurance);

    /// @notice The function to get the maximum insurance payout
    /// @return the maximum insurance payout in dexe
    function getMaxTreasuryPayout() external view returns (uint256);

    /// @notice The function to get the total number of accepted claims
    /// @return the number of accepted claims
    function acceptedClaimsCount() external view returns (uint256);

    /// @notice The paginated function to list accepted claims
    /// @param offset the starting index of the array
    /// @param limit the length of the observed window
    /// @return urls the IPFS URLs of the claims' evidence
    /// @return info the extended info of the claims
    function listAcceptedClaims(
        uint256 offset,
        uint256 limit
    ) external view returns (string[] memory urls, AcceptedClaims[] memory info);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ITraderPoolInvestorsHook.sol";
import "./ITraderPoolRiskyProposal.sol";
import "./ITraderPool.sol";

/**
 * This is the first type of pool that can de deployed by the trader in the DEXE platform.
 * BasicTraderPool inherits TraderPool functionality and adds the ability to invest into the risky proposals.
 * RiskyProposals are basically subpools where the trader is only allowed to open positions to the prespecified token.
 * Investors can enter subpools by allocating parts of their funds to the proposals. The allocation as done
 * through internal withdrawal and deposit process
 */
interface IBasicTraderPool is ITraderPoolInvestorsHook {
    /// @notice This function is used to create risky proposals (basically subpools) and allow investors to invest into it.
    /// The proposals follow pretty much the same rules as the main pool except that the trade can happen with a specified token only.
    /// Investors can't fund the proposal more than the trader percentage wise
    /// @param token the token the proposal will be opened to
    /// @param lpAmount the amount of LP tokens the trader would like to invest into the proposal at its creation
    /// @param proposalLimits the certain limits this proposal will have
    /// @param instantTradePercentage the percentage of LP tokens (base tokens under them) that will be traded to the proposal token
    /// @param minDivestOut is an array of minimal received amounts of positions on proposal creation (call getDivestAmountsAndCommissions()) to fetch this values
    /// @param minProposalOut is a minimal received amount of proposal position on proposal creation (call getCreationTokens()) to fetch this value
    /// @param optionalPath is an optional path between the base token and proposal token that will be used by the pathfinder
    function createProposal(
        address token,
        uint256 lpAmount,
        ITraderPoolRiskyProposal.ProposalLimits calldata proposalLimits,
        uint256 instantTradePercentage,
        uint256[] calldata minDivestOut,
        uint256 minProposalOut,
        address[] calldata optionalPath
    ) external;

    /// @notice This function invests into the created proposals. The function takes user's part of the pool, converts it to
    /// the base token and puts the funds into the proposal
    /// @param proposalId the id of the proposal a user would like to invest to
    /// @param lpAmount the amount of LP tokens to invest into the proposal
    /// @param minDivestOut the minimal received pool positions amounts
    /// @param minProposalOut the minimal amount of proposal tokens to receive
    function investProposal(
        uint256 proposalId,
        uint256 lpAmount,
        uint256[] calldata minDivestOut,
        uint256 minProposalOut
    ) external;

    /// @notice This function divests from the proposal and puts the funds back to the main pool
    /// @param proposalId the id of the proposal to divest from
    /// @param lp2Amount the amount of proposal LP tokens to be divested
    /// @param minInvestsOut the minimal amounts of main pool positions tokens to be received
    /// @param minProposalOut the minimal amount of base tokens received on a proposal divest
    function reinvestProposal(
        uint256 proposalId,
        uint256 lp2Amount,
        uint256[] calldata minInvestsOut,
        uint256 minProposalOut
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ITraderPoolInvestorsHook.sol";
import "./ITraderPoolInvestProposal.sol";
import "./ITraderPool.sol";

/**
 * This is the second type of the pool the trader is able to create in the DEXE platform. Similar to the BasicTraderPool,
 * it inherits the functionality of the TraderPool yet differs in the proposals implementation. Investors can fund the
 * investment proposals and the trader will be able to do whetever he wants to do with the received funds
 */
interface IInvestTraderPool is ITraderPoolInvestorsHook {
    /// @notice This function creates an investment proposal that users will be able to invest in
    /// @param descriptionURL the IPFS URL of the description document
    /// @param lpAmount the amount of LP tokens the trader will invest rightaway
    /// @param proposalLimits the certain limits this proposal will have
    /// @param minPositionsOut the amounts of base tokens received from positions to be invested into the proposal
    function createProposal(
        string calldata descriptionURL,
        uint256 lpAmount,
        ITraderPoolInvestProposal.ProposalLimits calldata proposalLimits,
        uint256[] calldata minPositionsOut
    ) external;

    /// @notice The function to invest into the proposal. Contrary to the RiskyProposal there is no percentage wise investment limit
    /// @param proposalId the id of the proposal to invest in
    /// @param lpAmount to amount of lpTokens to be invested into the proposal
    /// @param minPositionsOut the amounts of base tokens received from positions to be invested into the proposal
    function investProposal(
        uint256 proposalId,
        uint256 lpAmount,
        uint256[] calldata minPositionsOut
    ) external;

    /// @notice This function invests all the profit from the proposal into this pool
    /// @param proposalId the id of the proposal to take the profit from
    /// @param minPositionsOut the amounts of position tokens received on investment
    function reinvestProposal(uint256 proposalId, uint256[] calldata minPositionsOut) external;

    /// @notice This function returns a timestamp after which investors can start investing into the pool.
    /// The delay starts after opening the first position. Needed to minimize scam
    /// @return the timestamp after which the investment is allowed
    function getInvestDelayEnd() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../core/IPriceFeed.sol";
import "../core/ICoreProperties.sol";

/**
 * The TraderPool contract is a central business logic contract the DEXE platform is built around. The TraderPool represents
 * a collective pool where investors share its funds and the ownership. The share is represented with the LP tokens and the
 * income is made through the trader's activity. The pool itself is tidily integrated with the UniswapV2 protocol and the trader
 * is allowed to trade with the tokens in this pool. Several safety mechanisms are implemented here: Active Portfolio, Trader Leverage,
 * Proposals, Commissions horizon and simplified onchain PathFinder that protect the user funds
 */
interface ITraderPool {
    /// @notice The enum of exchange types
    /// @param FROM_EXACT the type corresponding to the exchangeFromExact function
    /// @param TO_EXACT the type corresponding to the exchangeToExact function
    enum ExchangeType {
        FROM_EXACT,
        TO_EXACT
    }

    /// @notice The struct that holds the parameters of this pool
    /// @param descriptionURL the IPFS URL of the description
    /// @param trader the address of trader of this pool
    /// @param privatePool the publicity of the pool. Of the pool is private, only private investors are allowed to invest into it
    /// @param totalLPEmission the total* number of pool's LP tokens. The investors are disallowed to invest more that this number
    /// @param baseToken the address of pool's base token
    /// @param baseTokenDecimals are the decimals of base token (just the gas savings)
    /// @param minimalInvestment is the minimal number of base tokens the investor is allowed to invest (in 18 decimals)
    /// @param commissionPeriod represents the duration of the commission period
    /// @param commissionPercentage trader's commission percentage (DEXE takes commission from this commission)
    struct PoolParameters {
        string descriptionURL;
        address trader;
        bool privatePool;
        uint256 totalLPEmission; // zero means unlimited
        address baseToken;
        uint256 baseTokenDecimals;
        uint256 minimalInvestment; // zero means any value
        ICoreProperties.CommissionPeriod commissionPeriod;
        uint256 commissionPercentage;
    }

    /// @notice The struct that stores basic investor's info
    /// @param investedBase the amount of base tokens the investor invested into the pool (normalized)
    /// @param commissionUnlockEpoch the commission epoch number the trader will be able to take commission from this investor
    struct InvestorInfo {
        uint256 investedBase;
        uint256 commissionUnlockEpoch;
    }

    /// @notice The struct that is returned from the TraderPoolView contract to see the taken commissions
    /// @param traderBaseCommission the total trader's commission in base tokens (normalized)
    /// @param traderLPCommission the equivalent trader's commission in LP tokens
    /// @param traderUSDCommission the equivalent trader's commission in USD (normalized)
    /// @param dexeBaseCommission the total platform's commission in base tokens (normalized)
    /// @param dexeLPCommission the equivalent platform's commission in LP tokens
    /// @param dexeUSDCommission the equivalent platform's commission in USD (normalized)
    /// @param dexeDexeCommission the equivalent platform's commission in DEXE tokens (normalized)
    struct Commissions {
        uint256 traderBaseCommission;
        uint256 traderLPCommission;
        uint256 traderUSDCommission;
        uint256 dexeBaseCommission;
        uint256 dexeLPCommission;
        uint256 dexeUSDCommission;
        uint256 dexeDexeCommission;
    }

    /// @notice The struct that is returned from the TraderPoolView contract to see the received amounts
    /// @param baseAmount total received base amount
    /// @param lpAmount total received LP amount (zero in getDivestAmountsAndCommissions())
    /// @param positions the addresses of positions tokens from which the "receivedAmounts" are calculated
    /// @param givenAmounts the amounts (either in base tokens or in position tokens) given
    /// @param receivedAmounts the amounts (either in base tokens or in position tokens) received
    struct Receptions {
        uint256 baseAmount;
        uint256 lpAmount;
        address[] positions;
        uint256[] givenAmounts;
        uint256[] receivedAmounts; // should be used as minAmountOut
    }

    /// @notice The struct that is returned from the TraderPoolView contract and stores information about the trader leverage
    /// @param totalPoolUSDWithProposals the total USD value of the pool + proposal pools
    /// @param traderLeverageUSDTokens the maximal amount of USD that the trader is allowed to own
    /// @param freeLeverageUSD the amount of USD that could be invested into the pool
    /// @param freeLeverageBase the amount of base tokens that could be invested into the pool (basically converted freeLeverageUSD)
    struct LeverageInfo {
        uint256 totalPoolUSDWithProposals;
        uint256 traderLeverageUSDTokens;
        uint256 freeLeverageUSD;
        uint256 freeLeverageBase;
    }

    /// @notice The struct that is returned from the TraderPoolView contract and stores information about the investor
    /// @param commissionUnlockTimestamp the timestamp after which the trader will be allowed to take the commission from this user
    /// @param poolLPBalance the LP token balance of this used excluding proposals balance. The same as calling .balanceOf() function
    /// @param investedBase the amount of base tokens invested into the pool (after commission calculation this might increase)
    /// @param poolUSDShare the equivalent amount of USD that represent the user's pool share
    /// @param poolUSDShare the equivalent amount of base tokens that represent the user's pool share
    /// @param owedBaseCommission the base commission the user will pay if the trader desides to claim commission now
    /// @param owedLPCommission the equivalent LP commission the user will pay if the trader desides to claim commission now
    struct UserInfo {
        uint256 commissionUnlockTimestamp;
        uint256 poolLPBalance;
        uint256 investedBase;
        uint256 poolUSDShare;
        uint256 poolBaseShare;
        uint256 owedBaseCommission;
        uint256 owedLPCommission;
    }

    /// @notice The structure that is returned from the TraderPoolView contract and stores static information about the pool
    /// @param ticker the ERC20 symbol of this pool
    /// @param name the ERC20 name of this pool
    /// @param parameters the active pool parameters (that are set in the constructor)
    /// @param openPositions the array of open positions addresses
    /// @param baseAndPositionBalances the array of balances. [0] is the balance of base tokens (array is normalized)
    /// @param totalBlacklistedPositions is the number of blacklisted positions this pool has
    /// @param totalInvestors is the number of investors this pools has (excluding trader)
    /// @param totalPoolUSD is the current USD TVL in this pool
    /// @param totalPoolBase is the current base token TVL in this pool
    /// @param lpSupply is the current number of LP tokens (without proposals)
    /// @param lpLockedInProposals is the current number of LP tokens that are locked in proposals
    /// @param traderUSD is the equivalent amount of USD that represent the trader's pool share
    /// @param traderBase is the equivalent amount of base tokens that represent the trader's pool share
    /// @param traderLPBalance is the amount of LP tokens the trader has in the pool (excluding proposals)
    struct PoolInfo {
        string ticker;
        string name;
        PoolParameters parameters;
        address[] openPositions;
        uint256[] baseAndPositionBalances;
        uint256 totalBlacklistedPositions;
        uint256 totalInvestors;
        uint256 totalPoolUSD;
        uint256 totalPoolBase;
        uint256 lpSupply;
        uint256 lpLockedInProposals;
        uint256 traderUSD;
        uint256 traderBase;
        uint256 traderLPBalance;
    }

    /// @notice The function that returns a PriceFeed contract
    /// @return the price feed used
    function priceFeed() external view returns (IPriceFeed);

    /// @notice The function that returns a CoreProperties contract
    /// @return the core properties contract
    function coreProperties() external view returns (ICoreProperties);

    /// @notice The function that checks whether the specified address is a private investor
    /// @param who the address to check
    /// @return true if the pool is private and who is a private investor, false otherwise
    function isPrivateInvestor(address who) external view returns (bool);

    /// @notice The function that checks whether the specified address is a trader admin
    /// @param who the address to check
    /// @return true if who is an admin, false otherwise
    function isTraderAdmin(address who) external view returns (bool);

    /// @notice The function that checks whether the specified address is a trader
    /// @param who the address to check
    /// @return true if who is a trader, false otherwise
    function isTrader(address who) external view returns (bool);

    /// @notice The function to modify trader admins. Trader admins are eligible for executing swaps
    /// @param admins the array of addresses to grant or revoke an admin rights
    /// @param add if true the admins will be added, if false the admins will be removed
    function modifyAdmins(address[] calldata admins, bool add) external;

    /// @notice The function to modify private investors
    /// @param privateInvestors the address to be added/removed from private investors list
    /// @param add if true the investors will be added, if false the investors will be removed
    function modifyPrivateInvestors(address[] calldata privateInvestors, bool add) external;

    /// @notice The function to change certain parameters of the pool
    /// @param descriptionURL the IPFS URL to new description
    /// @param privatePool the new access for this pool
    /// @param totalLPEmission the new LP emission for this pool
    /// @param minimalInvestment the new minimal investment bound
    function changePoolParameters(
        string calldata descriptionURL,
        bool privatePool,
        uint256 totalLPEmission,
        uint256 minimalInvestment
    ) external;

    /// @notice The function to invest into the pool. The "getInvestTokens" function has to be called to receive minPositionsOut amounts
    /// @param amountInBaseToInvest the amount of base tokens to be invested (normalized)
    /// @param minPositionsOut the minimal amounts of position tokens to be received
    function invest(uint256 amountInBaseToInvest, uint256[] calldata minPositionsOut) external;

    /// @notice The function that takes the commission from the users' income. This function should be called once per the
    /// commission period. Use "getReinvestCommissions()" function to get minDexeCommissionOut parameter
    /// @param offsetLimits the array of starting indexes and the lengths of the investors array.
    /// Starting indexes are under even positions, lengths are under odd
    /// @param minDexeCommissionOut the minimal amount of DEXE tokens the platform will receive
    function reinvestCommission(
        uint256[] calldata offsetLimits,
        uint256 minDexeCommissionOut
    ) external;

    /// @notice The function to divest from the pool. The "getDivestAmountsAndCommissions()" function should be called
    /// to receive minPositionsOut and minDexeCommissionOut parameters
    /// @param amountLP the amount of LP tokens to divest
    /// @param minPositionsOut the amount of positions tokens to be converted into the base tokens and given to the user
    /// @param minDexeCommissionOut the DEXE commission in DEXE tokens
    function divest(
        uint256 amountLP,
        uint256[] calldata minPositionsOut,
        uint256 minDexeCommissionOut
    ) external;

    /// @notice The function to exchange tokens for tokens
    /// @param from the tokens to exchange from
    /// @param to the token to exchange to
    /// @param amount the amount of tokens to be exchanged (normalized). If fromExact, this should equal amountIn, else amountOut
    /// @param amountBound this should be minAmountOut if fromExact, else maxAmountIn
    /// @param optionalPath the optional path between from and to tokens used by the pathfinder
    /// @param exType exchange type. Can be exchangeFromExact or exchangeToExact
    function exchange(
        address from,
        address to,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external;

    /// @notice The function to get an address of a proposal pool used by this contract
    /// @return the address of the proposal pool
    function proposalPoolAddress() external view returns (address);

    /// @notice The function that returns the actual LP emission (the totalSupply() might be less)
    /// @return the actual LP tokens emission
    function totalEmission() external view returns (uint256);

    /// @notice The function that check if the private investor can be removed
    /// @param investor private investor
    /// @return true if can be removed, false otherwise
    function canRemovePrivateInvestor(address investor) external view returns (bool);

    /// @notice The function to get the total number of investors
    /// @return the total number of investors
    function totalInvestors() external view returns (uint256);

    /// @notice The function that returns the filtered open positions list (filtered against the blacklist)
    /// @return the array of open positions
    function openPositions() external view returns (address[] memory);

    /// @notice The function that returns the information about the trader and investors
    /// @param user the exact user to receive information about
    /// @param offset the starting index of the investors array
    /// @param limit the length of the observed array
    /// @return usersInfo the information about the investors.
    /// [0] is the info about the requested user, [1] is the info about the trader, [1:] is the info about offset-limit investors
    function getUsersInfo(
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (UserInfo[] memory usersInfo);

    /// @notice The function to get the static pool information
    /// @return poolInfo the static info of the pool
    function getPoolInfo() external view returns (PoolInfo memory poolInfo);

    /// @notice The function to get the trader leverage information
    /// @return leverageInfo the trader leverage information
    function getLeverageInfo() external view returns (LeverageInfo memory leverageInfo);

    /// @notice The function to get the amounts of positions tokens that will be given to the investor on the investment
    /// @param amountInBaseToInvest normalized amount of base tokens to be invested
    /// @return receptions the information about the tokens received
    function getInvestTokens(
        uint256 amountInBaseToInvest
    ) external view returns (Receptions memory receptions);

    /// @notice The function to get the received commissions from the users when the "reinvestCommission" function is called.
    /// This function also "projects" commissions to the current positions if they were to be closed
    /// @param offsetLimits the starting indexes and the lengths of the investors array
    /// Starting indexes are under even positions, lengths are under odd
    /// @return commissions the received commissions info
    function getReinvestCommissions(
        uint256[] calldata offsetLimits
    ) external view returns (Commissions memory commissions);

    /// @notice The function to get the next commission epoch
    /// @return next commission epoch
    function getNextCommissionEpoch() external view returns (uint256);

    /// @notice The function to get the commissions and received tokens when the "divest" function is called
    /// @param user the address of the user who is going to divest
    /// @param amountLP the amount of LP tokens the users is going to divest
    /// @return receptions the tokens that the user will receive
    /// @return commissions the commissions the user will have to pay
    function getDivestAmountsAndCommissions(
        address user,
        uint256 amountLP
    ) external view returns (Receptions memory receptions, Commissions memory commissions);

    /// @notice The function to get token prices required for the slippage
    /// @param from the token to exchange from
    /// @param to the token to exchange to
    /// @param amount the amount of tokens to be exchanged. If fromExact, this should be amountIn, else amountOut
    /// @param optionalPath optional path between from and to tokens used by the pathfinder
    /// @param exType exchange type. Can be exchangeFromExact or exchangeToExact
    /// @return amount the minAmountOut if fromExact, else maxAmountIn
    /// @return path the tokens path that will be used during the swap
    function getExchangeAmount(
        address from,
        address to,
        uint256 amount,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external view returns (uint256, address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is an interface that is used in the proposals to add new investors upon token transfers
 */
interface ITraderPoolInvestorsHook {
    /// @notice The callback function that is called from _beforeTokenTransfer hook in the proposal contract.
    /// Needed to maintain the total investors amount
    /// @param user the transferrer of the funds
    function checkRemoveInvestor(address user) external;

    /// @notice The callback function that is called from _beforeTokenTransfer hook in the proposal contract.
    /// Needed to maintain the total investors amount
    /// @param user the receiver of the funds
    function checkNewInvestor(address user) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ITraderPoolProposal.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * This is the proposal the trader is able to create for the TraderInvestPool. The proposal itself is a subpool where investors
 * can send funds to. These funds become fully controlled by the trader himself and might be withdrawn for any purposes.
 * Anyone can supply funds to this kind of proposal and the funds will be distributed proportionally between all the proposal
 * investors
 */
interface ITraderPoolInvestProposal is ITraderPoolProposal {
    /// @notice The limits of this proposal
    /// @param timestampLimit the timestamp after which the proposal will close for the investments
    /// @param investLPLimit the maximal invested amount of LP tokens after which the proposal will close
    struct ProposalLimits {
        uint256 timestampLimit;
        uint256 investLPLimit;
    }

    /// @notice The struct that stores information about the proposal
    /// @param descriptionURL the IPFS URL of the proposal's description
    /// @param proposalLimits the limits of this proposal
    /// @param lpLocked the amount of LP tokens that are locked in this proposal
    /// @param investedBase the total amount of currently invested base tokens (this should never decrease because we don't burn LP)
    /// @param newInvestedBase the total amount of newly invested base tokens that the trader can withdraw
    struct ProposalInfo {
        string descriptionURL;
        ProposalLimits proposalLimits;
        uint256 lpLocked;
        uint256 investedBase;
        uint256 newInvestedBase;
    }

    /// @notice The struct that holds extra information about this proposal
    /// @param proposalInfo the information about this proposal
    /// @param lp2Supply the total supply of LP2 tokens
    /// @param totalInvestors the number of investors currently in this proposal
    struct ProposalInfoExtended {
        ProposalInfo proposalInfo;
        uint256 lp2Supply;
        uint256 totalInvestors;
    }

    /// @param cumulativeSums the helper values per rewarded token needed to calculate the investors' rewards
    /// @param rewardToken the set of rewarded token addresses
    struct RewardInfo {
        mapping(address => uint256) cumulativeSums; // with PRECISION
        EnumerableSet.AddressSet rewardTokens;
    }

    /// @notice The struct that stores the reward info about a single investor
    /// @param rewardsStored the amount of tokens the investor earned per rewarded token
    /// @param cumulativeSumsStored the helper variable needed to calculate investor's rewards per rewarded tokens
    struct UserRewardInfo {
        mapping(address => uint256) rewardsStored;
        mapping(address => uint256) cumulativeSumsStored; // with PRECISION
    }

    /// @notice The struct that is used by the TraderPoolInvestProposalView contract. It stores the information about
    /// currently active investor's proposals
    /// @param proposalId the id of the proposal
    /// @param lp2Balance investor's balance of proposal's LP tokens
    /// @param baseInvested the amount of invested base tokens by investor
    /// @param lpInvested the amount of invested LP tokens by investor
    struct ActiveInvestmentInfo {
        uint256 proposalId;
        uint256 lp2Balance;
        uint256 baseInvested;
        uint256 lpInvested;
    }

    /// @notice The struct that stores information about values of corresponding token addresses, used in the
    /// TraderPoolInvestProposalView contract
    /// @param amounts the amounts of underlying tokens
    /// @param tokens the correspoding token addresses
    struct Reception {
        uint256[] amounts;
        address[] tokens;
    }

    /// @notice The struct that is used by the TraderPoolInvestProposalView contract. It stores the information
    /// about the rewards
    /// @param totalBaseAmount is the overall value of reward tokens in usd (might not be correct due to limitations of pathfinder)
    /// @param totalBaseAmount is the overall value of reward tokens in base token (might not be correct due to limitations of pathfinder)
    /// @param baseAmountFromRewards the amount of base tokens that can be reinvested into the parent pool
    /// @param rewards the array of amounts and addresses of rewarded tokens (containts base tokens)
    struct Receptions {
        uint256 totalUsdAmount;
        uint256 totalBaseAmount;
        uint256 baseAmountFromRewards;
        Reception[] rewards;
    }

    /// @notice The function to change the proposal limits
    /// @param proposalId the id of the proposal to change
    /// @param proposalLimits the new limits for this proposal
    function changeProposalRestrictions(
        uint256 proposalId,
        ProposalLimits calldata proposalLimits
    ) external;

    /// @notice The function that creates proposals
    /// @param descriptionURL the IPFS URL of new description
    /// @param proposalLimits the certain limits of this proposal
    /// @param lpInvestment the amount of LP tokens invested on proposal's creation
    /// @param baseInvestment the equivalent amount of base tokens invested on proposal's creation
    /// @return proposalId the id of the created proposal
    function create(
        string calldata descriptionURL,
        ProposalLimits calldata proposalLimits,
        uint256 lpInvestment,
        uint256 baseInvestment
    ) external returns (uint256 proposalId);

    /// @notice The function that is used to invest into the proposal
    /// @param proposalId the id of the proposal
    /// @param user the user that invests
    /// @param lpInvestment the amount of LP tokens the user invests
    /// @param baseInvestment the equivalent amount of base tokens the user invests
    function invest(
        uint256 proposalId,
        address user,
        uint256 lpInvestment,
        uint256 baseInvestment
    ) external;

    /// @notice The function that is used to divest profit into the main pool from the specified proposal
    /// @param proposalId the id of the proposal to divest from
    /// @param user the user who divests
    /// @return the received amount of base tokens
    function divest(uint256 proposalId, address user) external returns (uint256);

    /// @notice The trader function to withdraw the invested funds to his wallet
    /// @param proposalId The id of the proposal to withdraw the funds from
    /// @param amount the amount of base tokens to withdraw (normalized)
    function withdraw(uint256 proposalId, uint256 amount) external;

    /// @notice The function to supply reward to the investors
    /// @param proposalId the id of the proposal to supply the funds to
    /// @param amounts the amounts of tokens to be supplied (normalized)
    /// @param addresses the addresses of tokens to be supplied
    function supply(
        uint256 proposalId,
        uint256[] calldata amounts,
        address[] calldata addresses
    ) external;

    /// @notice The function to convert newly invested funds to the rewards
    /// @param proposalId the id of the proposal
    function convertInvestedBaseToDividends(uint256 proposalId) external;

    /// @notice The function to get the information about the proposals
    /// @param offset the starting index of the proposals array
    /// @param limit the number of proposals to observe
    /// @return proposals the information about the proposals
    function getProposalInfos(
        uint256 offset,
        uint256 limit
    ) external view returns (ProposalInfoExtended[] memory proposals);

    /// @notice The function to get the information about the active proposals of this user
    /// @param user the user to observe
    /// @param offset the starting index of the invested proposals array
    /// @param limit the number of proposals to observe
    /// @return investments the information about the currently active investments
    function getActiveInvestmentsInfo(
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (ActiveInvestmentInfo[] memory investments);

    /// @notice The function that is used to get user's rewards from the proposals
    /// @param proposalIds the array of proposals ids
    /// @param user the user to get rewards of
    /// @return receptions the information about the received rewards
    function getRewards(
        uint256[] calldata proposalIds,
        address user
    ) external view returns (Receptions memory receptions);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../core/IPriceFeed.sol";

/**
 * This this the abstract TraderPoolProposal contract. This contract has 2 implementations:
 * TraderPoolRiskyProposal and TraderPoolInvestProposal. Each of these contracts goes as a supplementary contract
 * for TraderPool contracts. Traders are able to create special proposals that act as subpools where investors can invest to.
 * Each subpool has its own LP token that represents the pool's share
 */
interface ITraderPoolProposal {
    /// @notice The struct that stores information about the parent trader pool
    /// @param parentPoolAddress the address of the parent trader pool
    /// @param trader the address of the trader
    /// @param baseToken the address of the base tokens the parent trader pool has
    /// @param baseTokenDecimals the baseToken decimals
    struct ParentTraderPoolInfo {
        address parentPoolAddress;
        address trader;
        address baseToken;
        uint256 baseTokenDecimals;
    }

    /// @notice The function that returns the PriceFeed this proposal uses
    /// @return the price feed address
    function priceFeed() external view returns (IPriceFeed);

    /// @notice The function that returns the amount of currently locked LP tokens in all proposals
    /// @return the amount of locked LP tokens in all proposals
    function totalLockedLP() external view returns (uint256);

    /// @notice The function that returns the amount of currently invested base tokens into all proposals
    /// @return the amount of invested base tokens
    function investedBase() external view returns (uint256);

    /// @notice The function that returns total locked LP tokens amount of a specific user
    /// @param user the user to observe
    /// @return the total locked LP amount
    function totalLPBalances(address user) external view returns (uint256);

    /// @notice The function that returns base token address of the parent pool
    /// @return base token address
    function getBaseToken() external view returns (address);

    /// @notice The function that returns the amount of currently invested base tokens into all proposals in USD
    /// @return the amount of invested base tokens in USD equivalent
    function getInvestedBaseInUSD() external view returns (uint256);

    /// @notice The function to get the total amount of currently active investments of a specific user
    /// @param user the user to observe
    /// @return the amount of currently active investments of the user
    function getTotalActiveInvestments(address user) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ITraderPoolProposal.sol";

/**
 * This is the proposal the trader is able to create for the BasicTraderPool. This proposal is basically a simplified
 * version of a BasicTraderPool where a trader is only able to trade to a predefined token. The proposal itself encapsulates
 * investors and shares the profit only with the ones who invested into it
 */
interface ITraderPoolRiskyProposal is ITraderPoolProposal {
    /// @notice The enum of exchange types
    /// @param FROM_EXACT the type corresponding to the exchangeFromExact function
    /// @param TO_EXACT the type corresponding to the exchangeToExact function
    enum ExchangeType {
        FROM_EXACT,
        TO_EXACT
    }

    /// @notice The struct that stores certain proposal limits
    /// @param timestampLimit the timestamp after which the investment into this proposal closes
    /// @param investLPLimit the maximal number of invested LP tokens after which the investment into the proposal closes
    /// @param maxTokenPriceLimit the maximal price of the proposal token to the base token after which the investment into the proposal closes
    /// basically, if priceIn(base, token, 1) > maxTokenPriceLimit, the proposal closes for the investment
    struct ProposalLimits {
        uint256 timestampLimit;
        uint256 investLPLimit;
        uint256 maxTokenPriceLimit;
    }

    /// @notice The struct that holds the information of this proposal
    /// @param token the address of the proposal token
    /// @param tokenDecimals the decimals of the proposal token
    /// @param proposalLimits the investment limits of this proposal
    /// @param lpLocked the amount of LP tokens that are locked in this proposal
    /// @param balanceBase the base token balance of this proposal (normalized)
    /// @param balancePosition the position token balance of this proposal (normalized)
    struct ProposalInfo {
        address token;
        uint256 tokenDecimals;
        ProposalLimits proposalLimits;
        uint256 lpLocked;
        uint256 balanceBase;
        uint256 balancePosition;
    }

    /// @notice The struct that holds extra information about this proposal
    /// @param proposalInfo the information about this proposal
    /// @param totalProposalUSD the equivalent USD TVL in this proposal
    /// @param totalProposalBase the equivalent base TVL in this proposal
    /// @param totalInvestors the number of investors currently in this proposal
    /// @param positionTokenPrice the exact price on 1 position token in base tokens
    struct ProposalInfoExtended {
        ProposalInfo proposalInfo;
        uint256 totalProposalUSD;
        uint256 totalProposalBase;
        uint256 lp2Supply;
        uint256 totalInvestors;
        uint256 positionTokenPrice;
    }

    /// @notice The struct that is used in the "TraderPoolRiskyProposalView" contract and stores information about the investor's
    /// active investments
    /// @param proposalId the id of the proposal
    /// @param lp2Balance the investor's balance of proposal's LP tokens
    /// @param baseInvested the amount of invested base tokens by investor
    /// @param lpInvested the amount of invested LP tokens by investor
    /// @param baseShare the amount of investor's base token in this proposal
    /// @param positionShare the amount of investor's position token in this proposal
    struct ActiveInvestmentInfo {
        uint256 proposalId;
        uint256 lp2Balance;
        uint256 baseInvested;
        uint256 lpInvested;
        uint256 baseShare;
        uint256 positionShare;
    }

    /// @notice The struct that is used in the "TraderPoolRiskyProposalView" contract and stores information about the funds
    /// received on the divest action
    /// @param baseAmount the total amount of base tokens received
    /// @param positions the divested positions addresses
    /// @param givenAmounts the given amounts of tokens (in position tokens)
    /// @param receivedAmounts the received amounts of tokens (in base tokens)
    struct Receptions {
        uint256 baseAmount;
        address[] positions;
        uint256[] givenAmounts;
        uint256[] receivedAmounts; // should be used as minAmountOut
    }

    /// @notice The function to change the proposal investment restrictions
    /// @param proposalId the id of the proposal to change the restriction for
    /// @param proposalLimits the new limits for the proposal
    function changeProposalRestrictions(
        uint256 proposalId,
        ProposalLimits calldata proposalLimits
    ) external;

    /// @notice The function to create a proposal
    /// @param token the proposal token (the one that the trades are only allowed to)
    /// @param proposalLimits the investment limits for this proposal
    /// @param lpInvestment the amount of LP tokens invested rightaway
    /// @param baseInvestment the equivalent amount of baseToken invested rightaway
    /// @param instantTradePercentage the percentage of tokens that will be traded instantly to a "token"
    /// @param minPositionOut the minimal amount of position tokens received (call getCreationTokens())
    /// @param optionalPath the optional path between base token and position token that will be used by the pathfinder
    /// @return proposalId the id of the created proposal
    function create(
        address token,
        ProposalLimits calldata proposalLimits,
        uint256 lpInvestment,
        uint256 baseInvestment,
        uint256 instantTradePercentage,
        uint256 minPositionOut,
        address[] calldata optionalPath
    ) external returns (uint256 proposalId);

    /// @notice The function to invest into the proposal
    /// @param proposalId the id of the proposal to invest in
    /// @param user the investor
    /// @param lpInvestment the amount of LP tokens invested into the proposal
    /// @param baseInvestment the equivalent amount of baseToken invested into the proposal
    /// @param minPositionOut the minimal amount of position tokens received on proposal investment (call getInvestTokens())
    function invest(
        uint256 proposalId,
        address user,
        uint256 lpInvestment,
        uint256 baseInvestment,
        uint256 minPositionOut
    ) external;

    /// @notice The function to divest (reinvest) from a proposal
    /// @param proposalId the id of the proposal to divest from
    /// @param user the investor (or trader) who is divesting
    /// @param lp2 the amount of proposal LPs to divest
    /// @param minPositionOut the minimal amount of base tokens received from the position (call getDivestAmounts())
    /// @return received amount of base tokens
    function divest(
        uint256 proposalId,
        address user,
        uint256 lp2,
        uint256 minPositionOut
    ) external returns (uint256);

    /// @notice The function to exchange tokens for tokens in the specified proposal
    /// @param proposalId the proposal to exchange tokens in
    /// @param from the tokens to exchange from
    /// @param amount the amount of tokens to be exchanged (normalized). If fromExact, this should equal amountIn, else amountOut
    /// @param amountBound this should be minAmountOut if fromExact, else maxAmountIn
    /// @param optionalPath the optional path between from and to tokens used by the pathfinder
    /// @param exType exchange type. Can be exchangeFromExact or exchangeToExact
    function exchange(
        uint256 proposalId,
        address from,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external;

    /// @notice The function to get the information about the proposals
    /// @param offset the starting index of the proposals array
    /// @param limit the number of proposals to observe
    /// @return proposals the information about the proposals
    function getProposalInfos(
        uint256 offset,
        uint256 limit
    ) external view returns (ProposalInfoExtended[] memory proposals);

    /// @notice The function to get the amount of position token on proposal creation
    /// @param token the proposal token
    /// @param baseInvestment the amount of base tokens invested rightaway
    /// @param instantTradePercentage the percentage of tokens that will be traded instantly to a "token"
    /// @param optionalPath the optional path between base token and position token that will be used by the pathfinder
    /// @return positionTokens the amount of position tokens received upon creation
    /// @return positionTokenPrice the price of 1 proposal token to the base token
    /// @return path the tokens path that will be used during the swap
    function getCreationTokens(
        address token,
        uint256 baseInvestment,
        uint256 instantTradePercentage,
        address[] calldata optionalPath
    )
        external
        view
        returns (uint256 positionTokens, uint256 positionTokenPrice, address[] memory path);

    /// @notice The function to get the amount of base tokens and position tokens received on this proposal investment
    /// @param proposalId the id of the proposal to invest in
    /// @param baseInvestment the amount of base tokens to be invested (normalized)
    /// @return baseAmount the received amount of base tokens (normalized)
    /// @return positionAmount the received amount of position tokens (normalized)
    /// @return lp2Amount the amount of LP2 tokens received
    function getInvestTokens(
        uint256 proposalId,
        uint256 baseInvestment
    ) external view returns (uint256 baseAmount, uint256 positionAmount, uint256 lp2Amount);

    /// @notice The function to get the information about the active proposals of this user
    /// @param user the user to observe
    /// @param offset the starting index of the invested proposals array
    /// @param limit the number of proposals to observe
    /// @return investments the information about the currently active investments
    function getActiveInvestmentsInfo(
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (ActiveInvestmentInfo[] memory investments);

    /// @notice The function that returns the maximum allowed LP investment for the user
    /// @param user the user to get the investment limit for
    /// @param proposalIds the ids of the proposals to investigate the limits for
    /// @return lps the array of numbers representing the maximum allowed investment in LP tokens
    function getUserInvestmentsLimits(
        address user,
        uint256[] calldata proposalIds
    ) external view returns (uint256[] memory lps);

    /// @notice The function that returns the percentage of invested LPs agains the user's LP balance
    /// @param proposalId the proposal the user invested in
    /// @param user the proposal's investor to calculate percentage for
    /// @param toBeInvested LP amount the user is willing to invest
    /// @return the percentage of invested LPs + toBeInvested against the user's balance
    function getInvestmentPercentage(
        uint256 proposalId,
        address user,
        uint256 toBeInvested
    ) external view returns (uint256);

    /// @notice The function to get the received tokens on divest
    /// @param proposalIds the ids of the proposals to divest from
    /// @param lp2s the amounts of proposals LPs to be divested
    /// @return receptions the information about the received tokens
    function getDivestAmounts(
        uint256[] calldata proposalIds,
        uint256[] calldata lp2s
    ) external view returns (Receptions memory receptions);

    /// @notice The function to get token prices required for the slippage in the specified proposal
    /// @param proposalId the id of the proposal to get the prices in
    /// @param from the token to exchange from
    /// @param amount the amount of tokens to be exchanged. If fromExact, this should be amountIn, else amountOut
    /// @param optionalPath optional path between from and to tokens used by the pathfinder
    /// @return amount the minAmountOut if fromExact, else maxAmountIn
    /// @param exType exchange type. Can be exchangeFromExact or exchangeToExact
    function getExchangeAmount(
        uint256 proposalId,
        address from,
        uint256 amount,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external view returns (uint256, address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * This is the contract that stores user profile settings + his privacy policy agreement EIP712 signature
 */
interface IUserRegistry {
    /// @notice The structure that stores info about the user
    /// @param profileURL is an IPFS URL to the user's profile data
    /// @param signatureHash is a hash of a privacy policy signature
    struct UserInfo {
        string profileURL;
        bytes32 signatureHash;
    }

    /// @notice The function to change the user profile
    /// @param url the IPFS URL to the new profile settings
    function changeProfile(string calldata url) external;

    /// @notice The function to agree to the privacy policy of the DEXE platform.
    /// The user has to sign the hash of the privacy policy document
    /// @param signature the VRS packed parameters of the ECDSA signature
    function agreeToPrivacyPolicy(bytes calldata signature) external;

    /// @notice The function to change the profile and sign the privacy policy in a single transaction
    /// @param url the IPFS URL to the new profile settings
    /// @param signature the VRS packed parameters of the ECDSA signature
    function changeProfileAndAgreeToPrivacyPolicy(
        string calldata url,
        bytes calldata signature
    ) external;

    /// @notice The function to check whether the user signed the privacy policy
    /// @param user the user to check
    /// @return true is the user has signed to privacy policy, false otherwise
    function agreed(address user) external view returns (bool);

    /// @notice The function to set the hash of the document the user has to sign
    /// @param hash the has of the document the user has to sign
    function setPrivacyPolicyDocumentHash(bytes32 hash) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library ShrinkableArray {
    struct UintArray {
        uint256[] values;
        uint256 length;
    }

    /**
     * @dev Create `ShrinkableArray` from `uint256[]`, save original array and length
     */
    function transform(uint256[] memory arr) internal pure returns (UintArray memory) {
        return UintArray(arr, arr.length);
    }

    /**
     * @dev Create blank `ShrinkableArray` - empty array with original length
     */
    function create(uint256 length) internal pure returns (UintArray memory) {
        return UintArray(new uint256[](length), length);
    }

    /**
     * @dev Change array length
     */
    function crop(
        UintArray memory arr,
        uint256 newLength
    ) internal pure returns (UintArray memory) {
        arr.length = newLength;

        return arr;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../../interfaces/gov/IGovPool.sol";
import "../../interfaces/gov/user-keeper/IGovUserKeeper.sol";
import "../../interfaces/gov/settings/IGovSettings.sol";
import "../../interfaces/gov/validators/IGovValidators.sol";

import "../utils/DataHelper.sol";

import "../../gov/GovPool.sol";

library GovPoolCreate {
    using DataHelper for bytes;

    event ProposalCreated(
        uint256 proposalId,
        string proposalDescription,
        string misc,
        uint256 quorum,
        uint256 proposalSettings,
        address rewardToken,
        address sender
    );
    event DPCreated(uint256 proposalId, address sender, address token, uint256 amount);

    function createProposal(
        mapping(uint256 => IGovPool.Proposal) storage proposals,
        string calldata _descriptionURL,
        string calldata misc,
        address[] calldata executors,
        uint256[] calldata values,
        bytes[] calldata data
    ) external {
        require(
            executors.length > 0 &&
                executors.length == values.length &&
                executors.length == data.length,
            "Gov: invalid array length"
        );

        (
            IGovSettings.ProposalSettings memory settings,
            uint256 settingsId,
            uint256 snapshotId
        ) = _validateProposal(executors, values, data);

        uint256 proposalId = GovPool(payable(address(this))).latestProposalId();

        proposals[proposalId] = IGovPool.Proposal({
            core: IGovPool.ProposalCore({
                settings: settings,
                executed: false,
                voteEnd: uint64(block.timestamp + settings.duration),
                votesFor: 0,
                nftPowerSnapshotId: snapshotId
            }),
            descriptionURL: _descriptionURL,
            executors: executors,
            values: values,
            data: data
        });

        _canParticipate(settings, snapshotId);

        emit ProposalCreated(
            proposalId,
            _descriptionURL,
            misc,
            settings.quorum,
            settingsId,
            settings.rewardToken,
            msg.sender
        );
    }

    function moveProposalToValidators(
        mapping(uint256 => IGovPool.Proposal) storage proposals,
        uint256 proposalId
    ) external {
        IGovPool.ProposalCore storage core = proposals[proposalId].core;
        (, , address govValidators, ) = IGovPool(address(this)).getHelperContracts();

        require(
            IGovPool(address(this)).getProposalState(proposalId) ==
                IGovPool.ProposalState.WaitingForVotingTransfer,
            "Gov: can't be moved"
        );

        IGovValidators(govValidators).createExternalProposal(
            proposalId,
            core.settings.durationValidators,
            core.settings.quorumValidators
        );
    }

    function _canParticipate(
        IGovSettings.ProposalSettings memory settings,
        uint256 snapshotId
    ) internal view {
        (, address userKeeper, , ) = IGovPool(address(this)).getHelperContracts();

        require(
            IGovUserKeeper(userKeeper).canParticipate(
                msg.sender,
                false,
                !settings.delegatedVotingAllowed,
                settings.minVotesForCreating,
                snapshotId
            ),
            "Gov: low creating power"
        );
    }

    function _validateProposal(
        address[] calldata executors,
        uint256[] calldata values,
        bytes[] calldata data
    )
        internal
        returns (
            IGovSettings.ProposalSettings memory settings,
            uint256 settingsId,
            uint256 snapshotId
        )
    {
        (address govSettings, address userKeeper, , ) = IGovPool(address(this))
            .getHelperContracts();

        address mainExecutor = executors[executors.length - 1];
        settingsId = IGovSettings(govSettings).executorToSettings(mainExecutor);

        bool forceDefaultSettings;

        if (settingsId == uint256(IGovSettings.ExecutorType.INTERNAL)) {
            _handleDataForInternalProposal(govSettings, executors, values, data);
        } else if (settingsId == uint256(IGovSettings.ExecutorType.VALIDATORS)) {
            _handleDataForValidatorBalanceProposal(executors, values, data);
        } else if (settingsId == uint256(IGovSettings.ExecutorType.DISTRIBUTION)) {
            _handleDataForDistributionProposal(values, data);
        } else if (settingsId != uint256(IGovSettings.ExecutorType.DEFAULT)) {
            forceDefaultSettings = _handleDataForExistingSettingsProposal(values, data);
        }

        if (forceDefaultSettings) {
            settingsId = uint256(IGovSettings.ExecutorType.DEFAULT);
            settings = IGovSettings(govSettings).getDefaultSettings();
        } else {
            settings = IGovSettings(govSettings).getExecutorSettings(mainExecutor);
        }

        snapshotId = IGovUserKeeper(userKeeper).createNftPowerSnapshot();
    }

    function _handleDataForInternalProposal(
        address govSettings,
        address[] calldata executors,
        uint256[] calldata values,
        bytes[] calldata data
    ) internal view {
        for (uint256 i; i < data.length; i++) {
            bytes4 selector = data[i].getSelector();
            uint256 executorSettings = IGovSettings(govSettings).executorToSettings(executors[i]);

            require(
                values[i] == 0 &&
                    executorSettings == uint256(IGovSettings.ExecutorType.INTERNAL) &&
                    (selector == IGovSettings.addSettings.selector ||
                        selector == IGovSettings.editSettings.selector ||
                        selector == IGovSettings.changeExecutors.selector ||
                        selector == IGovUserKeeper.setERC20Address.selector ||
                        selector == IGovUserKeeper.setERC721Address.selector ||
                        selector == IGovPool.editDescriptionURL.selector ||
                        selector == IGovPool.setNftMultiplierAddress.selector),
                "Gov: invalid internal data"
            );
        }
    }

    function _handleDataForValidatorBalanceProposal(
        address[] calldata executors,
        uint256[] calldata values,
        bytes[] calldata data
    ) internal pure {
        require(executors.length == 1, "Gov: invalid executors length");

        for (uint256 i; i < data.length; i++) {
            bytes4 selector = data[i].getSelector();

            require(
                values[i] == 0 && (selector == IGovValidators.changeBalances.selector),
                "Gov: invalid internal data"
            );
        }
    }

    function _handleDataForDistributionProposal(
        uint256[] calldata values,
        bytes[] calldata data
    ) internal {
        (uint256 decodedId, address token, uint256 amount) = abi.decode(
            data[data.length - 1][4:],
            (uint256, address, uint256)
        );

        require(
            decodedId == GovPool(payable(address(this))).latestProposalId(),
            "Gov: invalid proposalId"
        );

        for (uint256 i; i < data.length - 1; i++) {
            bytes4 selector = data[i].getSelector();

            require(
                values[i] == 0 &&
                    (selector == IERC20.approve.selector || selector == IERC20.transfer.selector),
                "Gov: invalid internal data"
            );
        }

        emit DPCreated(decodedId, msg.sender, token, amount);
    }

    function _handleDataForExistingSettingsProposal(
        uint256[] calldata values,
        bytes[] calldata data
    ) internal pure returns (bool) {
        for (uint256 i; i < data.length - 1; i++) {
            bytes4 selector = data[i].getSelector();

            if (
                values[i] != 0 ||
                (selector != IERC20.approve.selector && // same as selector != IERC721.approve.selector
                    selector != IERC721.setApprovalForAll.selector) // same as IERC1155.setApprovalForAll.selector
            ) {
                return true; // should use default settings
            }
        }

        return false;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/Math.sol";

import "../../interfaces/gov/IGovPool.sol";
import "../../interfaces/gov/settings/IGovSettings.sol";
import "../../interfaces/gov/validators/IGovValidators.sol";

import "../utils/DataHelper.sol";
import "../math/MathHelper.sol";
import "../utils/TokenBalance.sol";

import "../../gov/GovPool.sol";

library GovPoolExecute {
    using DataHelper for bytes;
    using MathHelper for uint256;
    using Math for uint256;
    using TokenBalance for address;

    event ProposalExecuted(uint256 proposalId, address sender);

    function execute(
        mapping(uint256 => IGovPool.Proposal) storage proposals,
        uint256 proposalId
    ) external {
        IGovPool.Proposal storage proposal = proposals[proposalId];
        IGovPool.ProposalCore storage core = proposal.core;

        require(
            IGovPool(address(this)).getProposalState(proposalId) ==
                IGovPool.ProposalState.Succeeded,
            "Gov: invalid status"
        );

        core.executed = true;

        address[] memory executors = proposal.executors;
        uint256[] memory values = proposal.values;
        bytes[] memory data = proposal.data;

        for (uint256 i; i < data.length; i++) {
            (bool status, bytes memory returnedData) = executors[i].call{value: values[i]}(
                data[i]
            );

            require(status, returnedData.getRevertMsg());
        }

        emit ProposalExecuted(proposalId, msg.sender);

        _payCommission(core);
    }

    function _payCommission(IGovPool.ProposalCore storage core) internal {
        IGovSettings.ProposalSettings storage settings = core.settings;

        GovPool govPool = GovPool(payable(address(this)));

        address rewardToken = settings.rewardToken;
        (, uint256 commissionPercentage, , address[3] memory commissionReceivers) = govPool
            .coreProperties()
            .getDEXECommissionPercentages();

        if (rewardToken == address(0) || commissionReceivers[1] == address(this)) {
            return;
        }

        (, , address govValidators, ) = govPool.getHelperContracts();
        uint256 creationRewards = settings.creationReward *
            (
                settings.validatorsVote && IGovValidators(govValidators).validatorsCount() > 0
                    ? 2
                    : 1
            );

        uint256 totalRewards = creationRewards +
            settings.executionReward +
            core.votesFor.ratio(settings.voteRewardsCoefficient, PRECISION);

        uint256 commission = rewardToken.normThisBalance().min(
            totalRewards.percentage(commissionPercentage)
        );

        rewardToken.sendFunds(commissionReceivers[1], commission);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../interfaces/gov/IGovPool.sol";
import "../../interfaces/gov/ERC721/IERC721Multiplier.sol";

import "../utils/TokenBalance.sol";
import "../math/MathHelper.sol";

library GovPoolRewards {
    using TokenBalance for address;
    using MathHelper for uint256;

    event RewardClaimed(uint256 proposalId, address sender, address token, uint256 amount);
    event RewardCredited(uint256 proposalId, uint256 amount, address sender);

    function updateRewards(
        mapping(uint256 => mapping(address => uint256)) storage pendingRewards,
        uint256 proposalId,
        uint256 amount,
        uint256 coefficient
    ) external {
        address nftMultiplier = IGovPool(address(this)).nftMultiplier();
        uint256 amountToAdd = amount.ratio(coefficient, PRECISION);

        if (nftMultiplier != address(0)) {
            amountToAdd += IERC721Multiplier(nftMultiplier).getExtraRewards(
                msg.sender,
                amountToAdd
            );
        }

        pendingRewards[proposalId][msg.sender] += amountToAdd;

        emit RewardCredited(proposalId, amountToAdd, msg.sender);
    }

    function claimReward(
        mapping(uint256 => mapping(address => uint256)) storage pendingRewards,
        mapping(uint256 => IGovPool.Proposal) storage proposals,
        uint256 proposalId
    ) external {
        address rewardToken = proposals[proposalId].core.settings.rewardToken;

        require(rewardToken != address(0), "Gov: rewards are off");
        require(proposals[proposalId].core.executed, "Gov: proposal is not executed");

        uint256 rewards = pendingRewards[proposalId][msg.sender];

        require(rewardToken.normThisBalance() >= rewards, "Gov: not enough balance");

        delete pendingRewards[proposalId][msg.sender];

        rewardToken.sendFunds(msg.sender, rewards);

        emit RewardClaimed(proposalId, msg.sender, rewardToken, rewards);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../../interfaces/gov/IGovPool.sol";
import "../../interfaces/gov/user-keeper/IGovUserKeeper.sol";

library GovPoolUnlock {
    using Math for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    function unlockInProposals(
        mapping(address => mapping(bool => EnumerableSet.UintSet)) storage votedInProposals,
        mapping(uint256 => mapping(address => mapping(bool => IGovPool.VoteInfo)))
            storage voteInfos,
        uint256[] calldata proposalIds,
        address user,
        bool isMicropool
    ) external {
        IGovPool govPool = IGovPool(address(this));
        (, address userKeeper, , ) = govPool.getHelperContracts();

        EnumerableSet.UintSet storage userProposals = votedInProposals[user][isMicropool];

        uint256 maxLockedAmount = IGovUserKeeper(userKeeper).maxLockedAmount(user, isMicropool);
        uint256 maxUnlocked;

        for (uint256 i; i < proposalIds.length; i++) {
            uint256 proposalId = proposalIds[i];

            require(userProposals.contains(proposalId), "Gov: no vote for this proposal");

            IGovPool.ProposalState state = govPool.getProposalState(proposalId);

            if (
                state != IGovPool.ProposalState.Executed &&
                state != IGovPool.ProposalState.Succeeded &&
                state != IGovPool.ProposalState.Defeated
            ) {
                continue;
            }

            maxUnlocked = IGovUserKeeper(userKeeper)
                .unlockTokens(proposalId, user, isMicropool)
                .max(maxUnlocked);
            IGovUserKeeper(userKeeper).unlockNfts(
                voteInfos[proposalId][user][isMicropool].nftsVoted.values()
            );

            userProposals.remove(proposalId);
        }

        if (maxLockedAmount <= maxUnlocked) {
            IGovUserKeeper(userKeeper).updateMaxTokenLockedAmount(
                userProposals.values(),
                user,
                isMicropool
            );
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/libs/arrays/ArrayHelper.sol";

import "../../interfaces/gov/user-keeper/IGovUserKeeper.sol";
import "../../interfaces/gov/IGovPool.sol";
import "../../interfaces/gov/validators/IGovValidators.sol";

import "../data-structures/ShrinkableArray.sol";

import "../../core/Globals.sol";

library GovPoolView {
    using EnumerableSet for EnumerableSet.UintSet;
    using ArrayHelper for uint256[];
    using ShrinkableArray for uint256[];
    using ShrinkableArray for ShrinkableArray.UintArray;
    using Math for uint256;

    function getWithdrawableAssets(
        address user,
        mapping(address => mapping(bool => EnumerableSet.UintSet)) storage _votedInProposals,
        mapping(uint256 => mapping(address => mapping(bool => IGovPool.VoteInfo)))
            storage _voteInfos
    )
        external
        view
        returns (uint256 withdrawableTokens, ShrinkableArray.UintArray memory withdrawableNfts)
    {
        (
            ShrinkableArray.UintArray memory unlockedIds,
            ShrinkableArray.UintArray memory lockedIds
        ) = getUserProposals(user, false, _votedInProposals);

        uint256[] memory unlockedNfts = getUnlockedNfts(unlockedIds, user, false, _voteInfos);

        (, address userKeeper, , ) = IGovPool(address(this)).getHelperContracts();

        return IGovUserKeeper(userKeeper).getWithdrawableAssets(user, lockedIds, unlockedNfts);
    }

    function getUndelegateableAssets(
        address delegator,
        address delegatee,
        mapping(address => mapping(bool => EnumerableSet.UintSet)) storage _votedInProposals,
        mapping(uint256 => mapping(address => mapping(bool => IGovPool.VoteInfo)))
            storage _voteInfos
    )
        external
        view
        returns (uint256 undelegateableTokens, ShrinkableArray.UintArray memory undelegateableNfts)
    {
        (
            ShrinkableArray.UintArray memory unlockedIds,
            ShrinkableArray.UintArray memory lockedIds
        ) = getUserProposals(delegatee, true, _votedInProposals);

        uint256[] memory unlockedNfts = getUnlockedNfts(unlockedIds, delegatee, true, _voteInfos);

        (, address userKeeper, , ) = IGovPool(address(this)).getHelperContracts();

        return
            IGovUserKeeper(userKeeper).getUndelegateableAssets(
                delegator,
                delegatee,
                lockedIds,
                unlockedNfts
            );
    }

    function getUnlockedNfts(
        ShrinkableArray.UintArray memory unlockedIds,
        address user,
        bool isMicropool,
        mapping(uint256 => mapping(address => mapping(bool => IGovPool.VoteInfo)))
            storage _voteInfos
    ) internal view returns (uint256[] memory unlockedNfts) {
        uint256 totalLength;

        for (uint256 i; i < unlockedIds.length; i++) {
            totalLength += _voteInfos[unlockedIds.values[i]][user][isMicropool].nftsVoted.length();
        }

        unlockedNfts = new uint256[](totalLength);
        totalLength = 0;

        for (uint256 i; i < unlockedIds.length; i++) {
            IGovPool.VoteInfo storage voteInfo = _voteInfos[unlockedIds.values[i]][user][
                isMicropool
            ];

            totalLength = unlockedNfts.insert(totalLength, voteInfo.nftsVoted.values());
        }
    }

    function getUserProposals(
        address user,
        bool isMicropool,
        mapping(address => mapping(bool => EnumerableSet.UintSet)) storage _votedInProposals
    )
        internal
        view
        returns (
            ShrinkableArray.UintArray memory unlockedIds,
            ShrinkableArray.UintArray memory lockedIds
        )
    {
        EnumerableSet.UintSet storage votes = _votedInProposals[user][isMicropool];
        uint256 proposalsLength = votes.length();

        uint256[] memory unlockedProposals = new uint256[](proposalsLength);
        uint256[] memory lockedProposals = new uint256[](proposalsLength);
        uint256 unlockedLength;
        uint256 lockedLength;

        for (uint256 i; i < proposalsLength; i++) {
            uint256 proposalId = votes.at(i);

            IGovPool.ProposalState state = IGovPool(address(this)).getProposalState(proposalId);

            if (
                state == IGovPool.ProposalState.Executed ||
                state == IGovPool.ProposalState.Succeeded ||
                state == IGovPool.ProposalState.Defeated
            ) {
                unlockedProposals[unlockedLength++] = proposalId;
            } else {
                lockedProposals[lockedLength++] = proposalId;
            }
        }

        unlockedIds = unlockedProposals.transform().crop(unlockedLength);
        lockedIds = lockedProposals.transform().crop(lockedLength);
    }

    function getProposals(
        mapping(uint256 => IGovPool.Proposal) storage proposals,
        uint256 offset,
        uint256 limit
    ) internal view returns (IGovPool.ProposalView[] memory proposalViews) {
        IGovPool govPool = IGovPool(address(this));
        (, , address validators, ) = govPool.getHelperContracts();

        uint256 to = (offset + limit).min(govPool.latestProposalId()).max(offset);

        proposalViews = new IGovPool.ProposalView[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            proposalViews[i - offset] = IGovPool.ProposalView({
                proposal: proposals[i + 1],
                validatorProposal: IGovValidators(validators).getExternalProposal(i + 1),
                proposalState: govPool.getProposalState(i + 1),
                requiredQuorum: govPool.getProposalRequiredQuorum(i + 1),
                requiredValidatorsQuorum: IGovValidators(validators).getProposalRequiredQuorum(
                    i + 1,
                    false
                )
            });
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../../interfaces/gov/IGovPool.sol";
import "../../interfaces/gov/user-keeper/IGovUserKeeper.sol";

import "../../gov/GovPool.sol";

library GovPoolVote {
    using EnumerableSet for EnumerableSet.UintSet;

    event Voted(uint256 proposalId, address sender, uint256 personalVote, uint256 delegatedVote);

    function vote(
        mapping(uint256 => IGovPool.Proposal) storage proposals,
        mapping(address => mapping(bool => EnumerableSet.UintSet)) storage votedInProposals,
        mapping(uint256 => mapping(address => mapping(bool => IGovPool.VoteInfo)))
            storage voteInfos,
        uint256 proposalId,
        uint256 voteAmount,
        uint256[] calldata voteNftIds
    ) external returns (uint256) {
        require(voteAmount > 0 || voteNftIds.length > 0, "Gov: empty vote");

        bool useDelegated = !proposals[proposalId].core.settings.delegatedVotingAllowed;

        IGovPool.ProposalCore storage core = proposals[proposalId].core;
        EnumerableSet.UintSet storage votes = votedInProposals[msg.sender][false];
        IGovPool.VoteInfo storage voteInfo = voteInfos[proposalId][msg.sender][false];

        return
            _vote(core, votes, voteInfo, proposalId, voteAmount, voteNftIds, false, useDelegated);
    }

    function voteDelegated(
        mapping(uint256 => IGovPool.Proposal) storage proposals,
        mapping(address => mapping(bool => EnumerableSet.UintSet)) storage votedInProposals,
        mapping(uint256 => mapping(address => mapping(bool => IGovPool.VoteInfo)))
            storage voteInfos,
        uint256 proposalId,
        uint256 voteAmount,
        uint256[] calldata voteNftIds
    ) external returns (uint256) {
        require(voteAmount > 0 || voteNftIds.length > 0, "Gov: empty delegated vote");
        require(
            proposals[proposalId].core.settings.delegatedVotingAllowed,
            "Gov: delegated voting is off"
        );

        IGovPool.ProposalCore storage core = proposals[proposalId].core;
        EnumerableSet.UintSet storage votes = votedInProposals[msg.sender][true];
        IGovPool.VoteInfo storage voteInfo = voteInfos[proposalId][msg.sender][true];

        return _vote(core, votes, voteInfo, proposalId, voteAmount, voteNftIds, true, false);
    }

    function _vote(
        IGovPool.ProposalCore storage core,
        EnumerableSet.UintSet storage votes,
        IGovPool.VoteInfo storage voteInfo,
        uint256 proposalId,
        uint256 voteAmount,
        uint256[] calldata voteNftIds,
        bool isMicropool,
        bool useDelegated
    ) internal returns (uint256 reward) {
        _canParticipate(core, proposalId, isMicropool, useDelegated);

        votes.add(proposalId);

        require(
            votes.length() <= GovPool(payable(address(this))).coreProperties().getGovVotesLimit(),
            "Gov: vote limit reached"
        );

        _voteTokens(core, voteInfo, proposalId, voteAmount, isMicropool, useDelegated);
        reward = _voteNfts(core, voteInfo, voteNftIds, isMicropool, useDelegated) + voteAmount;

        emit Voted(proposalId, msg.sender, isMicropool ? 0 : reward, isMicropool ? reward : 0);
    }

    function _canParticipate(
        IGovPool.ProposalCore storage core,
        uint256 proposalId,
        bool isMicropool,
        bool useDelegated
    ) internal view {
        IGovPool govPool = IGovPool(address(this));
        (, address userKeeper, , ) = govPool.getHelperContracts();

        require(
            govPool.getProposalState(proposalId) == IGovPool.ProposalState.Voting,
            "Gov: vote unavailable"
        );
        require(
            IGovUserKeeper(userKeeper).canParticipate(
                msg.sender,
                isMicropool,
                useDelegated,
                core.settings.minVotesForVoting,
                core.nftPowerSnapshotId
            ),
            "Gov: low voting power"
        );
    }

    function _voteTokens(
        IGovPool.ProposalCore storage core,
        IGovPool.VoteInfo storage voteInfo,
        uint256 proposalId,
        uint256 amount,
        bool isMicropool,
        bool useDelegated
    ) internal {
        (, address userKeeper, , ) = IGovPool(address(this)).getHelperContracts();

        IGovUserKeeper(userKeeper).lockTokens(proposalId, msg.sender, isMicropool, amount);
        (uint256 tokenBalance, uint256 ownedBalance) = IGovUserKeeper(userKeeper).tokenBalance(
            msg.sender,
            isMicropool,
            useDelegated
        );

        require(
            amount <= tokenBalance - ownedBalance - voteInfo.tokensVoted,
            "Gov: wrong vote amount"
        );

        voteInfo.totalVoted += amount;
        voteInfo.tokensVoted += amount;

        core.votesFor += amount;
    }

    function _voteNfts(
        IGovPool.ProposalCore storage core,
        IGovPool.VoteInfo storage voteInfo,
        uint256[] calldata nftIds,
        bool isMicropool,
        bool useDelegated
    ) internal returns (uint256 voteAmount) {
        for (uint256 i; i < nftIds.length; i++) {
            require(voteInfo.nftsVoted.add(nftIds[i]), "Gov: NFT already voted");
        }

        (, address userKeeper, , ) = IGovPool(address(this)).getHelperContracts();

        IGovUserKeeper(userKeeper).lockNfts(msg.sender, isMicropool, useDelegated, nftIds);

        IGovUserKeeper(userKeeper).updateNftPowers(nftIds);

        voteAmount = IGovUserKeeper(userKeeper).getNftsPowerInTokensBySnapshot(
            nftIds,
            core.nftPowerSnapshotId
        );

        voteInfo.totalVoted += voteAmount;

        core.votesFor += voteAmount;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library GovUserKeeperLocal {
    function exec(
        function(address, address, uint256) external tokenFunc,
        address user,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }

        tokenFunc(msg.sender, user, amount);
    }

    function exec(
        function(address, address, uint256[] memory) external nftFunc,
        address user,
        uint256[] calldata nftIds
    ) internal {
        if (nftIds.length == 0) {
            return;
        }

        nftFunc(msg.sender, user, nftIds);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../../interfaces/gov/user-keeper/IGovUserKeeper.sol";

import "../../libs/data-structures/ShrinkableArray.sol";
import "../../libs/math/MathHelper.sol";

import "../../gov/ERC721/ERC721Power.sol";
import "../../gov/user-keeper/GovUserKeeper.sol";

library GovUserKeeperView {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using ShrinkableArray for uint256[];
    using ShrinkableArray for ShrinkableArray.UintArray;
    using MathHelper for uint256;
    using Math for uint256;

    function votingPower(
        address[] calldata users,
        bool[] calldata isMicropools,
        bool[] calldata useDelegated
    ) external view returns (IGovUserKeeper.VotingPowerView[] memory votingPowers) {
        GovUserKeeper userKeeper = GovUserKeeper(address(this));
        votingPowers = new IGovUserKeeper.VotingPowerView[](users.length);

        for (uint256 i = 0; i < users.length; i++) {
            IGovUserKeeper.VotingPowerView memory power = votingPowers[i];

            if (userKeeper.tokenAddress() != address(0)) {
                (power.power, power.ownedBalance) = userKeeper.tokenBalance(
                    users[i],
                    isMicropools[i],
                    useDelegated[i]
                );
            }

            if (userKeeper.nftAddress() != address(0)) {
                (power.nftIds, power.ownedLength) = userKeeper.nftExactBalance(
                    users[i],
                    isMicropools[i],
                    useDelegated[i]
                );
                (power.nftPower, power.perNftPower) = nftVotingPower(power.nftIds);

                power.power += power.nftPower;
            }
        }
    }

    function nftVotingPower(
        uint256[] memory nftIds
    ) public view returns (uint256 nftPower, uint256[] memory perNftPower) {
        GovUserKeeper userKeeper = GovUserKeeper(address(this));

        if (userKeeper.nftAddress() == address(0)) {
            return (nftPower, perNftPower);
        }

        ERC721Power nftContract = ERC721Power(userKeeper.nftAddress());
        IGovUserKeeper.NFTInfo memory nftInfo = userKeeper.getNftInfo();

        perNftPower = new uint256[](nftIds.length);

        if (!nftInfo.isSupportPower) {
            uint256 totalSupply = nftInfo.totalSupply == 0
                ? nftContract.totalSupply()
                : nftInfo.totalSupply;

            if (totalSupply > 0) {
                uint256 totalPower = nftInfo.totalPowerInTokens;

                for (uint256 i; i < nftIds.length; i++) {
                    perNftPower[i] = totalPower / totalSupply;
                }

                nftPower = nftIds.length.ratio(totalPower, totalSupply);
            }
        } else {
            uint256 totalNftsPower = nftContract.totalPower();

            if (totalNftsPower > 0) {
                uint256 totalPowerInTokens = nftInfo.totalPowerInTokens;

                for (uint256 i; i < nftIds.length; i++) {
                    perNftPower[i] = totalPowerInTokens.ratio(
                        nftContract.getNftPower(nftIds[i]),
                        totalNftsPower
                    );
                    nftPower += perNftPower[i];
                }
            }
        }
    }

    function delegations(
        address user,
        mapping(address => IGovUserKeeper.UserInfo) storage usersInfo
    )
        external
        view
        returns (uint256 power, IGovUserKeeper.DelegationInfoView[] memory delegationsInfo)
    {
        IGovUserKeeper.UserInfo storage userInfo = usersInfo[user];

        delegationsInfo = new IGovUserKeeper.DelegationInfoView[](userInfo.delegatees.length());

        for (uint256 i; i < delegationsInfo.length; i++) {
            IGovUserKeeper.DelegationInfoView memory delegation = delegationsInfo[i];
            address delegatee = userInfo.delegatees.at(i);

            delegation.delegatee = delegatee;
            delegation.delegatedTokens = userInfo.delegatedTokens[delegatee];
            delegation.delegatedNfts = userInfo.delegatedNfts[delegatee].values();
            (delegation.nftPower, delegation.perNftPower) = nftVotingPower(
                delegation.delegatedNfts
            );

            power += delegation.delegatedTokens + delegation.nftPower;
        }
    }

    function getUndelegateableAssets(
        address delegatee,
        ShrinkableArray.UintArray calldata lockedProposals,
        uint256[] calldata unlockedNfts,
        IGovUserKeeper.BalanceInfo storage balanceInfo,
        IGovUserKeeper.UserInfo storage delegatorInfo,
        mapping(uint256 => uint256) storage nftLockedNums
    )
        external
        view
        returns (uint256 undelegateableTokens, ShrinkableArray.UintArray memory undelegateableNfts)
    {
        (
            uint256 withdrawableTokens,
            ShrinkableArray.UintArray memory withdrawableNfts
        ) = _getFreeAssets(lockedProposals, unlockedNfts, balanceInfo, nftLockedNums);

        undelegateableTokens = delegatorInfo.delegatedTokens[delegatee].min(withdrawableTokens);
        EnumerableSet.UintSet storage delegatedNfts = delegatorInfo.delegatedNfts[delegatee];

        uint256[] memory nfts = new uint256[](withdrawableNfts.length);
        uint256 nftsLength;

        for (uint256 i; i < nfts.length; i++) {
            if (delegatedNfts.contains(withdrawableNfts.values[i])) {
                nfts[nftsLength++] = withdrawableNfts.values[i];
            }
        }

        undelegateableNfts = nfts.transform().crop(nftsLength);
    }

    function getWithdrawableAssets(
        ShrinkableArray.UintArray calldata lockedProposals,
        uint256[] calldata unlockedNfts,
        IGovUserKeeper.BalanceInfo storage balanceInfo,
        mapping(uint256 => uint256) storage nftLockedNums
    )
        external
        view
        returns (uint256 withdrawableTokens, ShrinkableArray.UintArray memory withdrawableNfts)
    {
        return _getFreeAssets(lockedProposals, unlockedNfts, balanceInfo, nftLockedNums);
    }

    function _getFreeAssets(
        ShrinkableArray.UintArray calldata lockedProposals,
        uint256[] calldata unlockedNfts,
        IGovUserKeeper.BalanceInfo storage balanceInfo,
        mapping(uint256 => uint256) storage nftLockedNums
    )
        private
        view
        returns (uint256 withdrawableTokens, ShrinkableArray.UintArray memory withdrawableNfts)
    {
        uint256 newLockedAmount;

        for (uint256 i; i < lockedProposals.length; i++) {
            newLockedAmount = newLockedAmount.max(
                balanceInfo.lockedInProposals[lockedProposals.values[i]]
            );
        }

        withdrawableTokens = balanceInfo.tokenBalance - newLockedAmount;

        uint256[] memory nfts = new uint256[](balanceInfo.nftBalance.length());
        uint256 nftsLength;

        for (uint256 i; i < nfts.length; i++) {
            uint256 nftId = balanceInfo.nftBalance.at(i);
            uint256 nftLockAmount = nftLockedNums[nftId];

            if (nftLockAmount != 0) {
                for (uint256 j = 0; j < unlockedNfts.length; j++) {
                    if (unlockedNfts[j] == nftId) {
                        nftLockAmount--;
                    }
                }
            }

            if (nftLockAmount == 0) {
                nfts[nftsLength++] = nftId;
            }
        }

        withdrawableNfts = nfts.transform().crop(nftsLength);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../core/Globals.sol";

library MathHelper {
    /// @notice percent has to be multiplied by PRECISION
    function percentage(uint256 num, uint256 percent) internal pure returns (uint256) {
        return (num * percent) / PERCENTAGE_100;
    }

    function ratio(uint256 base, uint256 num, uint256 denom) internal pure returns (uint256) {
        return (base * num) / denom;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../interfaces/core/IPriceFeed.sol";

import "../../core/Globals.sol";

library PriceFeedLocal {
    using SafeERC20 for IERC20;

    function checkAllowance(IPriceFeed priceFeed, address token) internal {
        if (IERC20(token).allowance(address(this), address(priceFeed)) == 0) {
            IERC20(token).safeApprove(address(priceFeed), MAX_UINT);
        }
    }

    function normExchangeFromExact(
        IPriceFeed priceFeed,
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] memory optionalPath,
        uint256 minAmountOut
    ) internal returns (uint256) {
        return
            priceFeed.normalizedExchangeFromExact(
                inToken,
                outToken,
                amountIn,
                optionalPath,
                minAmountOut
            );
    }

    function normExchangeToExact(
        IPriceFeed priceFeed,
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] memory optionalPath,
        uint256 maxAmountIn
    ) internal returns (uint256) {
        return
            priceFeed.normalizedExchangeToExact(
                inToken,
                outToken,
                amountOut,
                optionalPath,
                maxAmountIn
            );
    }

    function getNormPriceOut(
        IPriceFeed priceFeed,
        address inToken,
        address outToken,
        uint256 amountIn
    ) internal view returns (uint256 amountOut) {
        (amountOut, ) = priceFeed.getNormalizedPriceOut(inToken, outToken, amountIn);
    }

    function getNormPriceIn(
        IPriceFeed priceFeed,
        address inToken,
        address outToken,
        uint256 amountOut
    ) internal view returns (uint256 amountIn) {
        (amountIn, ) = priceFeed.getNormalizedPriceIn(inToken, outToken, amountOut);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../../interfaces/core/IPriceFeed.sol";

import "../../core/PriceFeed.sol";

library UniswapV2PathFinder {
    using EnumerableSet for EnumerableSet.AddressSet;

    function getUniV2PathWithPriceOut(
        EnumerableSet.AddressSet storage pathTokens,
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] calldata providedPath
    ) external view returns (IPriceFeed.FoundPath memory foundPath) {
        return
            _getPathWithPrice(
                pathTokens,
                inToken,
                outToken,
                amountIn,
                PriceFeed(address(this)).uniswapV2Router().getAmountsOut,
                _uniswapMore,
                providedPath
            );
    }

    function getUniV2PathWithPriceIn(
        EnumerableSet.AddressSet storage pathTokens,
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] calldata providedPath
    ) external view returns (IPriceFeed.FoundPath memory foundPath) {
        return
            _getPathWithPrice(
                pathTokens,
                inToken,
                outToken,
                amountOut,
                PriceFeed(address(this)).uniswapV2Router().getAmountsIn,
                _uniswapLess,
                providedPath
            );
    }

    function _getPathWithPrice(
        EnumerableSet.AddressSet storage pathTokens,
        address inToken,
        address outToken,
        uint256 amount,
        function(uint256, address[] memory) external view returns (uint256[] memory) priceFunction,
        function(uint256[] memory, uint256[] memory) internal pure returns (bool) compare,
        address[] calldata providedPath
    ) internal view returns (IPriceFeed.FoundPath memory foundPath) {
        if (amount == 0) {
            return IPriceFeed.FoundPath(new address[](0), new uint256[](0), true);
        }

        address[] memory path2 = new address[](2);
        path2[0] = inToken;
        path2[1] = outToken;

        try priceFunction(amount, path2) returns (uint256[] memory amounts) {
            foundPath.amounts = amounts;
            foundPath.path = path2;
        } catch {}

        uint256 length = pathTokens.length();

        for (uint256 i = 0; i < length; i++) {
            address[] memory path3 = new address[](3);
            path3[0] = inToken;
            path3[1] = pathTokens.at(i);
            path3[2] = outToken;

            try priceFunction(amount, path3) returns (uint256[] memory amounts) {
                if (foundPath.path.length == 0 || compare(amounts, foundPath.amounts)) {
                    foundPath.amounts = amounts;
                    foundPath.path = path3;
                }
            } catch {}
        }

        if (
            providedPath.length >= 3 &&
            providedPath[0] == inToken &&
            providedPath[providedPath.length - 1] == outToken
        ) {
            try priceFunction(amount, providedPath) returns (uint256[] memory amounts) {
                if (foundPath.path.length == 0 || compare(amounts, foundPath.amounts)) {
                    foundPath.amounts = amounts;
                    foundPath.path = providedPath;
                    foundPath.withProvidedPath = true;
                }
            } catch {}
        }
    }

    function _uniswapLess(
        uint256[] memory first,
        uint256[] memory second
    ) internal pure returns (bool) {
        return first[0] < second[0];
    }

    function _uniswapMore(
        uint256[] memory first,
        uint256[] memory second
    ) internal pure returns (bool) {
        return first[first.length - 1] > second[second.length - 1];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../../interfaces/trader/ITraderPoolInvestProposal.sol";
import "../../interfaces/core/IPriceFeed.sol";

import "../price-feed/PriceFeedLocal.sol";
import "../../libs/math/MathHelper.sol";

import "../../trader/TraderPoolInvestProposal.sol";

library TraderPoolInvestProposalView {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using MathHelper for uint256;
    using Math for uint256;
    using PriceFeedLocal for IPriceFeed;

    function getProposalInfos(
        mapping(uint256 => ITraderPoolInvestProposal.ProposalInfo) storage proposalInfos,
        mapping(uint256 => EnumerableSet.AddressSet) storage investors,
        uint256 offset,
        uint256 limit
    ) external view returns (ITraderPoolInvestProposal.ProposalInfoExtended[] memory proposals) {
        uint256 to = (offset + limit)
            .min(TraderPoolInvestProposal(address(this)).proposalsTotalNum())
            .max(offset);

        proposals = new ITraderPoolInvestProposal.ProposalInfoExtended[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            proposals[i - offset].proposalInfo = proposalInfos[i + 1];
            proposals[i - offset].lp2Supply = TraderPoolInvestProposal(address(this)).totalSupply(
                i + 1
            );
            proposals[i - offset].totalInvestors = investors[i + 1].length();
        }
    }

    function getActiveInvestmentsInfo(
        EnumerableSet.UintSet storage activeInvestments,
        mapping(address => mapping(uint256 => uint256)) storage baseBalances,
        mapping(address => mapping(uint256 => uint256)) storage lpBalances,
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (ITraderPoolInvestProposal.ActiveInvestmentInfo[] memory investments) {
        uint256 to = (offset + limit).min(activeInvestments.length()).max(offset);
        investments = new ITraderPoolInvestProposal.ActiveInvestmentInfo[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            uint256 proposalId = activeInvestments.at(i);

            investments[i - offset] = ITraderPoolInvestProposal.ActiveInvestmentInfo(
                proposalId,
                TraderPoolInvestProposal(address(this)).balanceOf(user, proposalId),
                baseBalances[user][proposalId],
                lpBalances[user][proposalId]
            );
        }
    }

    function getRewards(
        mapping(uint256 => ITraderPoolInvestProposal.RewardInfo) storage rewardInfos,
        mapping(address => mapping(uint256 => ITraderPoolInvestProposal.UserRewardInfo))
            storage userRewardInfos,
        uint256[] calldata proposalIds,
        address user
    ) external view returns (ITraderPoolInvestProposal.Receptions memory receptions) {
        receptions.rewards = new ITraderPoolInvestProposal.Reception[](proposalIds.length);

        IPriceFeed priceFeed = ITraderPoolInvestProposal(address(this)).priceFeed();
        uint256 proposalsTotalNum = TraderPoolInvestProposal(address(this)).proposalsTotalNum();
        address baseToken = ITraderPoolInvestProposal(address(this)).getBaseToken();

        for (uint256 i = 0; i < proposalIds.length; i++) {
            uint256 proposalId = proposalIds[i];

            if (proposalId == 0 || proposalId > proposalsTotalNum) {
                continue;
            }

            ITraderPoolInvestProposal.UserRewardInfo storage userRewardInfo = userRewardInfos[
                user
            ][proposalId];
            ITraderPoolInvestProposal.RewardInfo storage rewardInfo = rewardInfos[proposalId];

            uint256 balance = TraderPoolInvestProposal(address(this)).balanceOf(user, proposalId);

            receptions.rewards[i].tokens = rewardInfo.rewardTokens.values();
            receptions.rewards[i].amounts = new uint256[](receptions.rewards[i].tokens.length);

            for (uint256 j = 0; j < receptions.rewards[i].tokens.length; j++) {
                address token = receptions.rewards[i].tokens[j];

                receptions.rewards[i].amounts[j] =
                    userRewardInfo.rewardsStored[token] +
                    (rewardInfo.cumulativeSums[token] - userRewardInfo.cumulativeSumsStored[token])
                        .ratio(balance, PRECISION);

                if (token == baseToken) {
                    receptions.totalBaseAmount += receptions.rewards[i].amounts[j];
                    receptions.baseAmountFromRewards += receptions.rewards[i].amounts[j];
                } else {
                    receptions.totalBaseAmount += priceFeed.getNormPriceOut(
                        token,
                        baseToken,
                        receptions.rewards[i].amounts[j]
                    );
                }
            }

            (receptions.totalUsdAmount, ) = priceFeed.getNormalizedPriceOutUSD(
                baseToken,
                receptions.totalBaseAmount
            );
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../../interfaces/trader/ITraderPoolRiskyProposal.sol";
import "../../interfaces/core/IPriceFeed.sol";

import "../math/MathHelper.sol";
import "../price-feed/PriceFeedLocal.sol";

import "../../trader/TraderPoolRiskyProposal.sol";

library TraderPoolRiskyProposalView {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using MathHelper for uint256;
    using Math for uint256;
    using Address for address;
    using PriceFeedLocal for IPriceFeed;

    function getProposalInfos(
        mapping(uint256 => ITraderPoolRiskyProposal.ProposalInfo) storage proposalInfos,
        mapping(uint256 => EnumerableSet.AddressSet) storage investors,
        uint256 offset,
        uint256 limit
    ) external view returns (ITraderPoolRiskyProposal.ProposalInfoExtended[] memory proposals) {
        uint256 to = (offset + limit)
            .min(TraderPoolRiskyProposal(address(this)).proposalsTotalNum())
            .max(offset);

        proposals = new ITraderPoolRiskyProposal.ProposalInfoExtended[](to - offset);

        IPriceFeed priceFeed = ITraderPoolRiskyProposal(address(this)).priceFeed();
        address baseToken = ITraderPoolRiskyProposal(address(this)).getBaseToken();

        for (uint256 i = offset; i < to; i++) {
            proposals[i - offset].proposalInfo = proposalInfos[i + 1];

            proposals[i - offset].totalProposalBase =
                proposals[i - offset].proposalInfo.balanceBase +
                priceFeed.getNormPriceOut(
                    proposals[i - offset].proposalInfo.token,
                    baseToken,
                    proposals[i - offset].proposalInfo.balancePosition
                );
            (proposals[i - offset].totalProposalUSD, ) = priceFeed.getNormalizedPriceOutUSD(
                baseToken,
                proposals[i - offset].totalProposalBase
            );
            proposals[i - offset].lp2Supply = TraderPoolRiskyProposal(address(this)).totalSupply(
                i + 1
            );
            proposals[i - offset].totalInvestors = investors[i + 1].length();
            proposals[i - offset].positionTokenPrice = priceFeed.getNormPriceIn(
                baseToken,
                proposals[i - offset].proposalInfo.token,
                DECIMALS
            );
        }
    }

    function getActiveInvestmentsInfo(
        EnumerableSet.UintSet storage activeInvestments,
        mapping(address => mapping(uint256 => uint256)) storage baseBalances,
        mapping(address => mapping(uint256 => uint256)) storage lpBalances,
        mapping(uint256 => ITraderPoolRiskyProposal.ProposalInfo) storage proposalInfos,
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (ITraderPoolRiskyProposal.ActiveInvestmentInfo[] memory investments) {
        uint256 to = (offset + limit).min(activeInvestments.length()).max(offset);

        investments = new ITraderPoolRiskyProposal.ActiveInvestmentInfo[](to - offset);

        for (uint256 i = offset; i < to; i++) {
            uint256 proposalId = activeInvestments.at(i);
            uint256 balance = TraderPoolRiskyProposal(address(this)).balanceOf(user, proposalId);
            uint256 supply = TraderPoolRiskyProposal(address(this)).totalSupply(proposalId);

            investments[i - offset] = ITraderPoolRiskyProposal.ActiveInvestmentInfo(
                proposalId,
                balance,
                baseBalances[user][proposalId],
                lpBalances[user][proposalId],
                proposalInfos[proposalId].balanceBase.ratio(balance, supply),
                proposalInfos[proposalId].balancePosition.ratio(balance, supply)
            );
        }
    }

    function getUserInvestmentsLimits(
        ITraderPoolRiskyProposal.ParentTraderPoolInfo storage parentTraderPoolInfo,
        mapping(address => mapping(uint256 => uint256)) storage lpBalances,
        address user,
        uint256[] calldata proposalIds
    ) external view returns (uint256[] memory lps) {
        lps = new uint256[](proposalIds.length);

        ITraderPoolRiskyProposal proposal = ITraderPoolRiskyProposal(address(this));
        address trader = parentTraderPoolInfo.trader;

        uint256 lpBalance = proposal.totalLPBalances(user) +
            IERC20(parentTraderPoolInfo.parentPoolAddress).balanceOf(user);

        for (uint256 i = 0; i < proposalIds.length; i++) {
            if (user != trader) {
                uint256 proposalId = proposalIds[i];

                uint256 maxPercentage = proposal.getInvestmentPercentage(proposalId, trader, 0);
                uint256 maxInvestment = lpBalance.percentage(maxPercentage);

                lps[i] = maxInvestment > lpBalances[user][proposalId]
                    ? maxInvestment - lpBalances[user][proposalId]
                    : 0;
            } else {
                lps[i] = MAX_UINT;
            }
        }
    }

    function getCreationTokens(
        ITraderPoolRiskyProposal.ParentTraderPoolInfo storage parentTraderPoolInfo,
        address token,
        uint256 baseToExchange,
        address[] calldata optionalPath
    )
        external
        view
        returns (uint256 positionTokens, uint256 positionTokenPrice, address[] memory path)
    {
        address baseToken = parentTraderPoolInfo.baseToken;

        if (!token.isContract() || token == baseToken) {
            return (0, 0, new address[](0));
        }

        IPriceFeed priceFeed = ITraderPoolRiskyProposal(address(this)).priceFeed();

        (positionTokens, path) = priceFeed.getNormalizedExtendedPriceOut(
            baseToken,
            token,
            baseToExchange,
            optionalPath
        );
        (positionTokenPrice, ) = priceFeed.getNormalizedExtendedPriceIn(
            baseToken,
            token,
            DECIMALS,
            optionalPath
        );
    }

    function getInvestTokens(
        ITraderPoolRiskyProposal.ParentTraderPoolInfo storage parentTraderPoolInfo,
        ITraderPoolRiskyProposal.ProposalInfo storage info,
        uint256 proposalId,
        uint256 baseInvestment
    ) external view returns (uint256 baseAmount, uint256 positionAmount, uint256 lp2Amount) {
        if (
            proposalId == 0 ||
            proposalId > TraderPoolRiskyProposal(address(this)).proposalsTotalNum()
        ) {
            return (0, 0, 0);
        }

        IPriceFeed priceFeed = ITraderPoolRiskyProposal(address(this)).priceFeed();
        uint256 tokensPrice = priceFeed.getNormPriceOut(
            info.token,
            parentTraderPoolInfo.baseToken,
            info.balancePosition
        );
        uint256 totalBase = tokensPrice + info.balanceBase;

        lp2Amount = baseInvestment;
        baseAmount = baseInvestment;

        if (totalBase > 0) {
            uint256 baseToExchange = baseInvestment.ratio(tokensPrice, totalBase);

            baseAmount = baseInvestment - baseToExchange;
            positionAmount = priceFeed.getNormPriceOut(
                parentTraderPoolInfo.baseToken,
                info.token,
                baseToExchange
            );
            lp2Amount = lp2Amount.ratio(
                TraderPoolRiskyProposal(address(this)).totalSupply(proposalId),
                totalBase
            );
        }
    }

    function getDivestAmounts(
        ITraderPoolRiskyProposal.ParentTraderPoolInfo storage parentTraderPoolInfo,
        mapping(uint256 => ITraderPoolRiskyProposal.ProposalInfo) storage proposalInfos,
        uint256[] calldata proposalIds,
        uint256[] calldata lp2s
    ) external view returns (ITraderPoolRiskyProposal.Receptions memory receptions) {
        receptions.positions = new address[](proposalIds.length);
        receptions.givenAmounts = new uint256[](proposalIds.length);
        receptions.receivedAmounts = new uint256[](proposalIds.length);

        IPriceFeed priceFeed = ITraderPoolRiskyProposal(address(this)).priceFeed();
        uint256 proposalsTotalNum = TraderPoolRiskyProposal(address(this)).proposalsTotalNum();

        for (uint256 i = 0; i < proposalIds.length; i++) {
            uint256 proposalId = proposalIds[i];

            if (proposalId == 0 || proposalId > proposalsTotalNum) {
                continue;
            }

            uint256 propSupply = TraderPoolRiskyProposal(address(this)).totalSupply(proposalId);

            if (propSupply > 0) {
                receptions.positions[i] = proposalInfos[proposalId].token;
                receptions.givenAmounts[i] = proposalInfos[proposalId].balancePosition.ratio(
                    lp2s[i],
                    propSupply
                );
                receptions.receivedAmounts[i] = priceFeed.getNormPriceOut(
                    proposalInfos[proposalId].token,
                    parentTraderPoolInfo.baseToken,
                    receptions.givenAmounts[i]
                );

                receptions.baseAmount +=
                    proposalInfos[proposalId].balanceBase.ratio(lp2s[i], propSupply) +
                    receptions.receivedAmounts[i];
            }
        }
    }

    function getExchangeAmount(
        ITraderPoolRiskyProposal.ParentTraderPoolInfo storage parentTraderPoolInfo,
        address positionToken,
        uint256 proposalId,
        address from,
        uint256 amount,
        address[] calldata optionalPath,
        ITraderPoolRiskyProposal.ExchangeType exType
    ) external view returns (uint256, address[] memory) {
        if (
            proposalId == 0 ||
            proposalId > TraderPoolRiskyProposal(address(this)).proposalsTotalNum()
        ) {
            return (0, new address[](0));
        }

        address baseToken = parentTraderPoolInfo.baseToken;
        address to;

        if (from != baseToken && from != positionToken) {
            return (0, new address[](0));
        }

        if (from == baseToken) {
            to = positionToken;
        } else {
            to = baseToken;
        }

        IPriceFeed priceFeed = ITraderPoolRiskyProposal(address(this)).priceFeed();

        return
            exType == ITraderPoolRiskyProposal.ExchangeType.FROM_EXACT
                ? priceFeed.getNormalizedExtendedPriceOut(from, to, amount, optionalPath)
                : priceFeed.getNormalizedExtendedPriceIn(from, to, amount, optionalPath);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "../../interfaces/trader/ITraderPool.sol";
import "../../interfaces/core/ICoreProperties.sol";

import "../../trader/TraderPool.sol";

import "../../libs/math/MathHelper.sol";
import "../../libs/utils/TokenBalance.sol";

library TraderPoolCommission {
    using DecimalsConverter for uint256;
    using MathHelper for uint256;
    using SafeERC20 for IERC20;
    using TokenBalance for address;

    function sendDexeCommission(
        IERC20 dexeToken,
        uint256 dexeCommission,
        uint256[] calldata poolPercentages,
        address[3] calldata commissionReceivers
    ) external {
        for (uint256 i = 0; i < commissionReceivers.length; i++) {
            dexeToken.safeTransfer(
                commissionReceivers[i],
                dexeCommission.percentage(poolPercentages[i])
            );
        }
    }

    function calculateCommissionOnReinvest(
        ITraderPool.PoolParameters storage poolParameters,
        address investor,
        uint256 oldTotalSupply
    )
        external
        view
        returns (uint256 investorBaseAmount, uint256 baseCommission, uint256 lpCommission)
    {
        uint256 investorBalance = IERC20(address(this)).balanceOf(investor);
        uint256 baseTokenBalance = poolParameters.baseToken.normThisBalance();

        investorBaseAmount = baseTokenBalance.ratio(investorBalance, oldTotalSupply);

        (baseCommission, lpCommission) = calculateCommissionOnDivest(
            poolParameters,
            investor,
            investorBaseAmount,
            investorBalance
        );
    }

    function calculateCommissionOnDivest(
        ITraderPool.PoolParameters storage poolParameters,
        address investor,
        uint256 investorBaseAmount,
        uint256 amountLP
    ) public view returns (uint256 baseCommission, uint256 lpCommission) {
        uint256 balance = IERC20(address(this)).balanceOf(investor);

        if (balance > 0) {
            (uint256 investedBase, ) = TraderPool(address(this)).investorsInfo(investor);
            investedBase = investedBase.ratio(amountLP, balance);

            (baseCommission, lpCommission) = _calculateInvestorCommission(
                poolParameters,
                investorBaseAmount,
                amountLP,
                investedBase
            );
        }
    }

    function nextCommissionEpoch(
        ITraderPool.PoolParameters storage poolParameters
    ) external view returns (uint256) {
        return
            ITraderPool(address(this)).coreProperties().getCommissionEpochByTimestamp(
                block.timestamp,
                poolParameters.commissionPeriod
            );
    }

    function calculateDexeCommission(
        uint256 baseToDistribute,
        uint256 lpToDistribute,
        uint256 dexePercentage
    ) external pure returns (uint256 lpCommission, uint256 baseCommission) {
        lpCommission = lpToDistribute.percentage(dexePercentage);
        baseCommission = baseToDistribute.percentage(dexePercentage);
    }

    function _calculateInvestorCommission(
        ITraderPool.PoolParameters storage poolParameters,
        uint256 investorBaseAmount,
        uint256 investorLPAmount,
        uint256 investedBaseAmount
    ) internal view returns (uint256 baseCommission, uint256 lpCommission) {
        if (investorBaseAmount > investedBaseAmount) {
            baseCommission = (investorBaseAmount - investedBaseAmount).percentage(
                poolParameters.commissionPercentage
            );
            lpCommission = investorLPAmount.ratio(baseCommission, investorBaseAmount);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../../interfaces/trader/ITraderPool.sol";
import "../../interfaces/core/IPriceFeed.sol";
import "../../interfaces/core/ICoreProperties.sol";

import "../price-feed/PriceFeedLocal.sol";
import "../utils/TokenBalance.sol";

library TraderPoolExchange {
    using EnumerableSet for EnumerableSet.AddressSet;
    using PriceFeedLocal for IPriceFeed;
    using TokenBalance for address;

    event Exchanged(
        address sender,
        address fromToken,
        address toToken,
        uint256 fromVolume,
        uint256 toVolume
    );
    event PositionClosed(address position);

    function exchange(
        ITraderPool.PoolParameters storage poolParameters,
        EnumerableSet.AddressSet storage positions,
        address from,
        address to,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ITraderPool.ExchangeType exType
    ) external {
        ICoreProperties coreProperties = ITraderPool(address(this)).coreProperties();
        IPriceFeed priceFeed = ITraderPool(address(this)).priceFeed();

        require(from != to, "TP: ambiguous exchange");
        require(
            !coreProperties.isBlacklistedToken(from) && !coreProperties.isBlacklistedToken(to),
            "TP: blacklisted token"
        );
        require(
            from == poolParameters.baseToken || positions.contains(from),
            "TP: invalid exchange address"
        );

        priceFeed.checkAllowance(from);
        priceFeed.checkAllowance(to);

        if (to != poolParameters.baseToken) {
            positions.add(to);
        }

        uint256 amountGot;

        if (exType == ITraderPool.ExchangeType.FROM_EXACT) {
            _checkThisBalance(amount, from);
            amountGot = priceFeed.normExchangeFromExact(
                from,
                to,
                amount,
                optionalPath,
                amountBound
            );
        } else {
            _checkThisBalance(amountBound, from);
            amountGot = priceFeed.normExchangeToExact(from, to, amount, optionalPath, amountBound);

            (amount, amountGot) = (amountGot, amount);
        }

        emit Exchanged(msg.sender, from, to, amount, amountGot);

        if (from != poolParameters.baseToken && from.thisBalance() == 0) {
            positions.remove(from);

            emit PositionClosed(from);
        }

        require(
            positions.length() <= coreProperties.getMaximumOpenPositions(),
            "TP: max positions"
        );
    }

    function getExchangeAmount(
        ITraderPool.PoolParameters storage poolParameters,
        EnumerableSet.AddressSet storage positions,
        address from,
        address to,
        uint256 amount,
        address[] calldata optionalPath,
        ITraderPool.ExchangeType exType
    ) external view returns (uint256, address[] memory) {
        IPriceFeed priceFeed = ITraderPool(address(this)).priceFeed();
        ICoreProperties coreProperties = ITraderPool(address(this)).coreProperties();

        if (coreProperties.isBlacklistedToken(from) || coreProperties.isBlacklistedToken(to)) {
            return (0, new address[](0));
        }

        if (from == to || (from != poolParameters.baseToken && !positions.contains(from))) {
            return (0, new address[](0));
        }

        return
            exType == ITraderPool.ExchangeType.FROM_EXACT
                ? priceFeed.getNormalizedExtendedPriceOut(from, to, amount, optionalPath)
                : priceFeed.getNormalizedExtendedPriceIn(from, to, amount, optionalPath);
    }

    function _checkThisBalance(uint256 amount, address token) internal view {
        require(amount <= token.normThisBalance(), "TP: invalid exchange amount");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/trader/ITraderPool.sol";
import "../../interfaces/trader/ITraderPoolProposal.sol";
import "../../interfaces/core/IPriceFeed.sol";
import "../../interfaces/core/ICoreProperties.sol";

import "./TraderPoolPrice.sol";
import "../../libs/math/MathHelper.sol";

library TraderPoolLeverage {
    using MathHelper for uint256;
    using TraderPoolPrice for ITraderPool.PoolParameters;

    function getMaxTraderLeverage(
        ITraderPool.PoolParameters storage poolParameters
    ) public view returns (uint256 totalTokensUSD, uint256 maxTraderLeverageUSDTokens) {
        uint256 traderUSDTokens;

        (totalTokensUSD, traderUSDTokens) = _getNormalizedLeveragePoolPriceInUSD(poolParameters);
        (uint256 threshold, uint256 slope) = ITraderPool(address(this))
            .coreProperties()
            .getTraderLeverageParams();

        int256 traderUSD = int256(traderUSDTokens / DECIMALS);
        int256 multiplier = traderUSD / int256(threshold);

        int256 numerator = int256(threshold) +
            ((multiplier + 1) * (2 * traderUSD - int256(threshold))) -
            (multiplier * multiplier * int256(threshold));

        int256 boost = traderUSD * 2;

        maxTraderLeverageUSDTokens = uint256((numerator / int256(slope) + boost)) * DECIMALS;
    }

    function checkLeverage(
        ITraderPool.PoolParameters storage poolParameters,
        uint256 amountInBaseToInvest
    ) external view {
        if (msg.sender == poolParameters.trader) {
            return;
        }

        (uint256 totalPriceInUSD, uint256 maxTraderVolumeInUSD) = getMaxTraderLeverage(
            poolParameters
        );
        (uint256 addInUSD, ) = ITraderPool(address(this)).priceFeed().getNormalizedPriceOutUSD(
            poolParameters.baseToken,
            amountInBaseToInvest
        );

        require(addInUSD + totalPriceInUSD <= maxTraderVolumeInUSD, "TP: leverage exceeded");
    }

    function _getNormalizedLeveragePoolPriceInUSD(
        ITraderPool.PoolParameters storage poolParameters
    ) internal view returns (uint256 totalInUSD, uint256 traderInUSD) {
        address trader = poolParameters.trader;
        address proposalPool = ITraderPool(address(this)).proposalPoolAddress();
        uint256 totalEmission = ITraderPool(address(this)).totalEmission();
        uint256 traderBalance = IERC20(address(this)).balanceOf(trader);

        (, totalInUSD) = poolParameters.getNormalizedPoolPriceAndUSD();

        if (proposalPool != address(0)) {
            totalInUSD += ITraderPoolProposal(proposalPool).getInvestedBaseInUSD();
            traderBalance += ITraderPoolProposal(proposalPool).totalLPBalances(trader);
        }

        if (totalEmission > 0) {
            traderInUSD = totalInUSD.ratio(traderBalance, totalEmission);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../../interfaces/trader/ITraderPool.sol";
import "../../interfaces/core/IPriceFeed.sol";

import "../../libs/utils/TokenBalance.sol";

library TraderPoolPrice {
    using EnumerableSet for EnumerableSet.AddressSet;
    using TokenBalance for address;

    function getNormalizedPoolPriceAndUSD(
        ITraderPool.PoolParameters storage poolParameters
    ) external view returns (uint256 totalBase, uint256 totalUSD) {
        (totalBase, , , ) = getNormalizedPoolPriceAndPositions(poolParameters);

        (totalUSD, ) = ITraderPool(address(this)).priceFeed().getNormalizedPriceOutUSD(
            poolParameters.baseToken,
            totalBase
        );
    }

    function getNormalizedPoolPriceAndPositions(
        ITraderPool.PoolParameters storage poolParameters
    )
        public
        view
        returns (
            uint256 totalPriceInBase,
            uint256 currentBaseAmount,
            address[] memory positionTokens,
            uint256[] memory positionPricesInBase
        )
    {
        IPriceFeed priceFeed = ITraderPool(address(this)).priceFeed();
        address[] memory openPositions = ITraderPool(address(this)).openPositions();
        totalPriceInBase = currentBaseAmount = poolParameters.baseToken.normThisBalance();

        positionTokens = new address[](openPositions.length);
        positionPricesInBase = new uint256[](openPositions.length);

        for (uint256 i = 0; i < openPositions.length; i++) {
            positionTokens[i] = openPositions[i];

            (positionPricesInBase[i], ) = priceFeed.getNormalizedPriceOut(
                positionTokens[i],
                poolParameters.baseToken,
                positionTokens[i].normThisBalance()
            );

            totalPriceInBase += positionPricesInBase[i];
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "../../interfaces/trader/ITraderPool.sol";
import "../../interfaces/core/IPriceFeed.sol";

import "../../trader/TraderPool.sol";

import "./TraderPoolPrice.sol";
import "./TraderPoolCommission.sol";
import "./TraderPoolLeverage.sol";
import "../math/MathHelper.sol";
import "../utils/TokenBalance.sol";
import "../price-feed/PriceFeedLocal.sol";

library TraderPoolView {
    using EnumerableSet for EnumerableSet.AddressSet;
    using TraderPoolPrice for ITraderPool.PoolParameters;
    using TraderPoolPrice for address;
    using TraderPoolCommission for ITraderPool.PoolParameters;
    using TraderPoolLeverage for ITraderPool.PoolParameters;
    using DecimalsConverter for uint256;
    using MathHelper for uint256;
    using Math for uint256;
    using TokenBalance for address;
    using PriceFeedLocal for IPriceFeed;

    function getUsersInfo(
        ITraderPool.PoolParameters storage poolParameters,
        EnumerableSet.AddressSet storage investors,
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (ITraderPool.UserInfo[] memory usersInfo) {
        uint256 to = (offset + limit).min(investors.length()).max(offset);

        (uint256 totalPoolBase, uint256 totalPoolUSD) = poolParameters
            .getNormalizedPoolPriceAndUSD();
        uint256 totalSupply = IERC20(address(this)).totalSupply();

        usersInfo = new ITraderPool.UserInfo[](to - offset + 2);

        if (investors.contains(user)) {
            usersInfo[0] = _getUserInfo(
                poolParameters,
                user,
                totalPoolBase,
                totalPoolUSD,
                totalSupply
            );
        }

        usersInfo[1] = _getUserInfo(
            poolParameters,
            poolParameters.trader,
            totalPoolBase,
            totalPoolUSD,
            totalSupply
        );

        for (uint256 i = offset; i < to; i++) {
            usersInfo[i - offset + 2] = _getUserInfo(
                poolParameters,
                investors.at(i),
                totalPoolBase,
                totalPoolUSD,
                totalSupply
            );
        }
    }

    function getPoolInfo(
        ITraderPool.PoolParameters storage poolParameters,
        EnumerableSet.AddressSet storage positions
    ) external view returns (ITraderPool.PoolInfo memory poolInfo) {
        poolInfo.ticker = ERC20(address(this)).symbol();
        poolInfo.name = ERC20(address(this)).name();

        poolInfo.parameters = poolParameters;
        poolInfo.openPositions = ITraderPool(address(this)).openPositions();

        poolInfo.baseAndPositionBalances = new uint256[](poolInfo.openPositions.length + 1);
        poolInfo.baseAndPositionBalances[0] = poolInfo.parameters.baseToken.normThisBalance();

        for (uint256 i = 0; i < poolInfo.openPositions.length; i++) {
            poolInfo.baseAndPositionBalances[i + 1] = poolInfo.openPositions[i].normThisBalance();
        }

        poolInfo.totalBlacklistedPositions = positions.length() - poolInfo.openPositions.length;
        poolInfo.totalInvestors = ITraderPool(address(this)).totalInvestors();

        (poolInfo.totalPoolBase, poolInfo.totalPoolUSD) = poolParameters
            .getNormalizedPoolPriceAndUSD();

        poolInfo.lpSupply = IERC20(address(this)).totalSupply();
        poolInfo.lpLockedInProposals =
            ITraderPool(address(this)).totalEmission() -
            poolInfo.lpSupply;

        if (poolInfo.lpSupply > 0) {
            poolInfo.traderLPBalance = IERC20(address(this)).balanceOf(poolParameters.trader);
            poolInfo.traderUSD = poolInfo.totalPoolUSD.ratio(
                poolInfo.traderLPBalance,
                poolInfo.lpSupply
            );
            poolInfo.traderBase = poolInfo.totalPoolBase.ratio(
                poolInfo.traderLPBalance,
                poolInfo.lpSupply
            );
        }
    }

    function getLeverageInfo(
        ITraderPool.PoolParameters storage poolParameters
    ) external view returns (ITraderPool.LeverageInfo memory leverageInfo) {
        (
            leverageInfo.totalPoolUSDWithProposals,
            leverageInfo.traderLeverageUSDTokens
        ) = poolParameters.getMaxTraderLeverage();

        if (leverageInfo.traderLeverageUSDTokens > leverageInfo.totalPoolUSDWithProposals) {
            leverageInfo.freeLeverageUSD =
                leverageInfo.traderLeverageUSDTokens -
                leverageInfo.totalPoolUSDWithProposals;
            (leverageInfo.freeLeverageBase, ) = ITraderPool(address(this))
                .priceFeed()
                .getNormalizedPriceInUSD(poolParameters.baseToken, leverageInfo.freeLeverageUSD);
        }
    }

    function getInvestTokens(
        ITraderPool.PoolParameters storage poolParameters,
        uint256 amountInBaseToInvest
    ) external view returns (ITraderPool.Receptions memory receptions) {
        (
            uint256 totalBase,
            uint256 currentBaseAmount,
            address[] memory positionTokens,
            uint256[] memory positionPricesInBase
        ) = poolParameters.getNormalizedPoolPriceAndPositions();

        receptions.lpAmount = amountInBaseToInvest;
        receptions.positions = positionTokens;
        receptions.givenAmounts = new uint256[](positionTokens.length);
        receptions.receivedAmounts = new uint256[](positionTokens.length);

        if (totalBase > 0) {
            IPriceFeed priceFeed = ITraderPool(address(this)).priceFeed();

            receptions.baseAmount = currentBaseAmount.ratio(amountInBaseToInvest, totalBase);
            receptions.lpAmount = receptions.lpAmount.ratio(
                IERC20(address(this)).totalSupply(),
                totalBase
            );

            for (uint256 i = 0; i < positionTokens.length; i++) {
                receptions.givenAmounts[i] = positionPricesInBase[i].ratio(
                    amountInBaseToInvest,
                    totalBase
                );
                receptions.receivedAmounts[i] = priceFeed.getNormPriceOut(
                    poolParameters.baseToken,
                    positionTokens[i],
                    receptions.givenAmounts[i]
                );
            }
        }
    }

    function getReinvestCommissions(
        ITraderPool.PoolParameters storage poolParameters,
        EnumerableSet.AddressSet storage investors,
        uint256[] calldata offsetLimits
    ) external view returns (ITraderPool.Commissions memory commissions) {
        (uint256 totalPoolBase, ) = poolParameters.getNormalizedPoolPriceAndUSD();
        uint256 totalSupply = IERC20(address(this)).totalSupply();

        uint256 allBaseCommission;
        uint256 allLPCommission;

        for (uint256 i = 0; i < offsetLimits.length; i += 2) {
            uint256 to = (offsetLimits[i] + offsetLimits[i + 1]).min(investors.length()).max(
                offsetLimits[i]
            );

            for (uint256 j = offsetLimits[i]; j < to; j++) {
                address investor = investors.at(j);

                (uint256 baseCommission, uint256 lpCommission) = _getReinvestCommission(
                    poolParameters,
                    investor,
                    totalPoolBase,
                    totalSupply
                );

                allBaseCommission += baseCommission;
                allLPCommission += lpCommission;
            }
        }

        return
            _getTraderAndPlatformCommissions(poolParameters, allBaseCommission, allLPCommission);
    }

    function getDivestAmountsAndCommissions(
        ITraderPool.PoolParameters storage poolParameters,
        address investor,
        uint256 amountLP
    )
        external
        view
        returns (
            ITraderPool.Receptions memory receptions,
            ITraderPool.Commissions memory commissions
        )
    {
        ERC20 baseToken = ERC20(poolParameters.baseToken);
        IPriceFeed priceFeed = ITraderPool(address(this)).priceFeed();
        address[] memory openPositions = ITraderPool(address(this)).openPositions();

        uint256 totalSupply = IERC20(address(this)).totalSupply();

        receptions.positions = new address[](openPositions.length);
        receptions.givenAmounts = new uint256[](openPositions.length);
        receptions.receivedAmounts = new uint256[](openPositions.length);

        if (totalSupply > 0) {
            receptions.baseAmount = baseToken
                .balanceOf(address(this))
                .ratio(amountLP, totalSupply)
                .to18(baseToken.decimals());

            for (uint256 i = 0; i < openPositions.length; i++) {
                receptions.positions[i] = openPositions[i];
                receptions.givenAmounts[i] = ERC20(receptions.positions[i])
                    .balanceOf(address(this))
                    .ratio(amountLP, totalSupply)
                    .to18(ERC20(receptions.positions[i]).decimals());

                receptions.receivedAmounts[i] = priceFeed.getNormPriceOut(
                    receptions.positions[i],
                    address(baseToken),
                    receptions.givenAmounts[i]
                );
                receptions.baseAmount += receptions.receivedAmounts[i];
            }

            if (investor != poolParameters.trader) {
                (uint256 baseCommission, uint256 lpCommission) = poolParameters
                    .calculateCommissionOnDivest(investor, receptions.baseAmount, amountLP);

                commissions = _getTraderAndPlatformCommissions(
                    poolParameters,
                    baseCommission,
                    lpCommission
                );
            }
        }
    }

    function _getUserInfo(
        ITraderPool.PoolParameters storage poolParameters,
        address user,
        uint256 totalPoolBase,
        uint256 totalPoolUSD,
        uint256 totalSupply
    ) internal view returns (ITraderPool.UserInfo memory userInfo) {
        ICoreProperties coreProperties = ITraderPool(address(this)).coreProperties();

        userInfo.poolLPBalance = IERC20(address(this)).balanceOf(user);

        if (userInfo.poolLPBalance > 0) {
            (userInfo.investedBase, userInfo.commissionUnlockTimestamp) = TraderPool(address(this))
                .investorsInfo(user);

            userInfo.poolUSDShare = totalPoolUSD.ratio(userInfo.poolLPBalance, totalSupply);
            userInfo.poolBaseShare = totalPoolBase.ratio(userInfo.poolLPBalance, totalSupply);

            if (userInfo.commissionUnlockTimestamp > 0) {
                (userInfo.owedBaseCommission, userInfo.owedLPCommission) = poolParameters
                    .calculateCommissionOnDivest(
                        user,
                        userInfo.poolBaseShare,
                        userInfo.poolLPBalance
                    );
            }
        }

        userInfo.commissionUnlockTimestamp = userInfo.commissionUnlockTimestamp == 0
            ? coreProperties.getCommissionEpochByTimestamp(
                block.timestamp,
                poolParameters.commissionPeriod
            )
            : userInfo.commissionUnlockTimestamp;

        userInfo.commissionUnlockTimestamp = coreProperties.getCommissionTimestampByEpoch(
            userInfo.commissionUnlockTimestamp,
            poolParameters.commissionPeriod
        );
    }

    function _getReinvestCommission(
        ITraderPool.PoolParameters storage poolParameters,
        address investor,
        uint256 totalPoolBase,
        uint256 totalSupply
    ) internal view returns (uint256 baseCommission, uint256 lpCommission) {
        (, uint256 commissionUnlockEpoch) = TraderPool(address(this)).investorsInfo(investor);

        if (poolParameters.nextCommissionEpoch() > commissionUnlockEpoch) {
            uint256 lpBalance = IERC20(address(this)).balanceOf(investor);
            uint256 baseShare = totalPoolBase.ratio(lpBalance, totalSupply);

            (baseCommission, lpCommission) = poolParameters.calculateCommissionOnDivest(
                investor,
                baseShare,
                lpBalance
            );
        }
    }

    function _getTraderAndPlatformCommissions(
        ITraderPool.PoolParameters storage poolParameters,
        uint256 baseCommission,
        uint256 lpCommission
    ) internal view returns (ITraderPool.Commissions memory commissions) {
        IPriceFeed priceFeed = ITraderPool(address(this)).priceFeed();
        (uint256 dexePercentage, , , ) = ITraderPool(address(this))
            .coreProperties()
            .getDEXECommissionPercentages();

        (uint256 usdCommission, ) = priceFeed.getNormalizedPriceOutUSD(
            poolParameters.baseToken,
            baseCommission
        );

        commissions.dexeBaseCommission = baseCommission.percentage(dexePercentage);
        commissions.dexeLPCommission = lpCommission.percentage(dexePercentage);
        commissions.dexeUSDCommission = usdCommission.percentage(dexePercentage);

        commissions.traderBaseCommission = baseCommission - commissions.dexeBaseCommission;
        commissions.traderLPCommission = lpCommission - commissions.dexeLPCommission;
        commissions.traderUSDCommission = usdCommission - commissions.dexeUSDCommission;

        (commissions.dexeDexeCommission, ) = priceFeed.getNormalizedPriceOutDEXE(
            poolParameters.baseToken,
            commissions.dexeBaseCommission
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library AddressSetHelper {
    using EnumerableSet for EnumerableSet.AddressSet;

    function add(EnumerableSet.AddressSet storage addressSet, address[] calldata array) internal {
        for (uint256 i = 0; i < array.length; i++) {
            addressSet.add(array[i]);
        }
    }

    function remove(
        EnumerableSet.AddressSet storage addressSet,
        address[] calldata array
    ) internal {
        for (uint256 i = 0; i < array.length; i++) {
            addressSet.remove(array[i]);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library DataHelper {
    function getSelector(bytes calldata data) internal pure returns (bytes4 selector) {
        assembly {
            selector := calldataload(data.offset)
        }
    }

    function getRevertMsg(bytes memory data) internal pure returns (string memory) {
        if (data.length < 68) {
            return "Transaction reverted silently";
        }

        assembly {
            data := add(data, 0x04)
        }

        return abi.decode(data, (string));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "../../core/Globals.sol";

library TokenBalance {
    using DecimalsConverter for uint256;
    using SafeERC20 for IERC20;

    function sendFunds(address token, address receiver, uint256 amount) internal {
        if (token == ETHEREUM_ADDRESS) {
            (bool status, ) = payable(receiver).call{value: amount}("");
            require(status, "Gov: failed to send eth");
        } else {
            IERC20(token).safeTransfer(receiver, amount.from18(ERC20(token).decimals()));
        }
    }

    function thisBalance(address token) internal view returns (uint256) {
        return
            token == ETHEREUM_ADDRESS
                ? address(this).balance
                : IERC20(token).balanceOf(address(this));
    }

    function normThisBalance(address token) internal view returns (uint256) {
        return
            token == ETHEREUM_ADDRESS
                ? thisBalance(token)
                : thisBalance(token).to18(ERC20(token).decimals());
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../core/PriceFeed.sol";

import "../../libs/math/MathHelper.sol";

contract PriceFeedMock is PriceFeed {
    using SafeERC20 for IERC20;
    using MathHelper for uint256;

    function exchangeFromExact(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] memory,
        uint256 minAmountOut
    ) public override returns (uint256) {
        if (amountIn == 0) {
            return 0;
        }

        _grabTokens(inToken, amountIn);

        address[] memory path = new address[](2);

        path[0] = inToken;
        path[1] = outToken;

        uint256[] memory outs = uniswapV2Router.swapExactTokensForTokens(
            amountIn,
            minAmountOut,
            path,
            msg.sender,
            block.timestamp
        );

        return outs[outs.length - 1];
    }

    function exchangeToExact(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] memory,
        uint256 maxAmountIn
    ) public override returns (uint256) {
        if (amountOut == 0) {
            return 0;
        }

        _grabTokens(inToken, maxAmountIn);

        address[] memory path = new address[](2);

        path[0] = inToken;
        path[1] = outToken;

        uint256[] memory ins = uniswapV2Router.swapTokensForExactTokens(
            amountOut,
            maxAmountIn,
            path,
            msg.sender,
            block.timestamp
        );

        IERC20(inToken).safeTransfer(msg.sender, maxAmountIn - ins[0]);

        return ins[0];
    }

    function getExtendedPriceOut(
        address inToken,
        address outToken,
        uint256 amountIn,
        address[] memory
    ) public view override returns (uint256, address[] memory) {
        if (amountIn == 0) {
            return (0, new address[](0));
        }

        address[] memory path = new address[](2);

        path[0] = inToken;
        path[1] = outToken;

        uint256[] memory outs = uniswapV2Router.getAmountsOut(amountIn, path);

        return (outs[outs.length - 1], path);
    }

    function getExtendedPriceIn(
        address inToken,
        address outToken,
        uint256 amountOut,
        address[] memory
    ) public view override returns (uint256, address[] memory) {
        if (amountOut == 0) {
            return (0, new address[](0));
        }

        address[] memory path = new address[](2);

        path[0] = inToken;
        path[1] = outToken;

        uint256[] memory ins = uniswapV2Router.getAmountsIn(amountOut, path);

        return (ins[0], path);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UniswapV2RouterMock {
    using SafeERC20 for IERC20;

    mapping(address => uint256) public reserves;

    mapping(address => mapping(address => uint256)) public bonuses;

    mapping(address => mapping(address => address)) public pairs;

    function enablePair(address tokenA, address tokenB) external {
        pairs[tokenA][tokenB] = address(1);
        pairs[tokenB][tokenA] = address(1);
    }

    function setBonuses(address tokenA, address tokenB, uint256 amount) external {
        bonuses[tokenA][tokenB] = amount;
    }

    function setReserve(address token, uint256 amount) external {
        uint256 balance = IERC20(token).balanceOf(address(this));

        reserves[token] = amount;

        if (amount > balance) {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount - balance);
        } else if (amount < balance) {
            IERC20(token).safeTransfer(msg.sender, balance - amount);
        }
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256
    ) external returns (uint256[] memory amounts) {
        amounts = getAmountsOut(amountIn, path);

        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT"
        );

        _swap(amounts, path, to);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256
    ) external returns (uint256[] memory amounts) {
        amounts = getAmountsIn(amountOut, path);

        require(amounts[0] <= amountInMax, "UniswapV2Router: EXCESSIVE_INPUT_AMOUNT");

        _swap(amounts, path, to);
    }

    function getAmountsOut(
        uint256 amountIn,
        address[] memory path
    ) public view returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");

        amounts = new uint256[](path.length);
        amounts[0] = amountIn;

        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = _getReserves(path[i], path[i + 1]);
            amounts[i + 1] =
                _getAmountOut(amounts[i], reserveIn, reserveOut) +
                bonuses[path[i]][path[i + 1]];
        }
    }

    function getAmountsIn(
        uint256 amountOut,
        address[] memory path
    ) public view returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");

        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;

        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = _getReserves(path[i - 1], path[i]);
            amounts[i - 1] =
                _getAmountIn(amounts[i], reserveIn, reserveOut) -
                bonuses[path[i]][path[i - 1]];
        }
    }

    function getPair(address tokenA, address tokenB) external view returns (address) {
        return pairs[tokenA][tokenB];
    }

    function _swap(uint256[] memory amounts, address[] memory path, address _to) internal virtual {
        IERC20(path[0]).safeTransferFrom(msg.sender, address(this), amounts[0]);
        IERC20(path[path.length - 1]).safeTransfer(_to, amounts[amounts.length - 1]);

        for (uint256 i; i < path.length; i++) {
            reserves[path[i]] = IERC20(path[i]).balanceOf(address(this));
        }
    }

    function _getReserves(
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        require(
            pairs[tokenA][tokenB] != address(0) || pairs[tokenB][tokenA] != address(0),
            "UniswapV2Library: PAIR_DOES_NOT_EXIST"
        );

        return (reserves[tokenA], reserves[tokenB]);
    }

    /// @dev modified formula for simplicity
    function _getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");

        amountIn = (amountOut * reserveIn) / reserveOut;
    }

    /// @dev modified formula for simplicity
    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");

        amountOut = (amountIn * reserveOut) / reserveIn;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract ExecutorTransferMock is ERC721Holder, ERC1155Holder {
    address public govAddress;
    address public mock20Address;

    uint256 public amount20;

    constructor(address _govAddress, address _mock20Address) {
        govAddress = _govAddress;
        mock20Address = _mock20Address;
    }

    function setTransferAmount(uint256 _amount20) external {
        amount20 = _amount20;
    }

    function execute() external payable {
        address _govAddress = govAddress;

        if (amount20 > 0) {
            IERC20(mock20Address).transferFrom(_govAddress, address(this), amount20);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../../libs/data-structures/ShrinkableArray.sol";

contract ShrinkableArrayMock {
    using ShrinkableArray for *;

    function transform(
        uint256[] calldata arr
    ) external pure returns (ShrinkableArray.UintArray memory) {
        return arr.transform();
    }

    function create(uint256 length) external pure returns (ShrinkableArray.UintArray memory) {
        return length.create();
    }

    function crop(
        ShrinkableArray.UintArray calldata arr,
        uint256 newLength
    ) external pure returns (ShrinkableArray.UintArray memory) {
        return arr.crop(newLength);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    uint8 internal _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimalPlaces
    ) ERC20(name, symbol) {
        _decimals = decimalPlaces;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function mint(address to, uint256 _amount) public {
        _mint(to, _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20Mock.sol";

contract ERC20MockUpgraded is ERC20Mock {
    uint256 public importantVariable;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimalPlaces
    ) ERC20Mock(name, symbol, decimalPlaces) {}

    function doUpgrade(uint256 value) external {
        importantVariable = value;
    }

    function addedFunction() external pure returns (uint256) {
        return 42;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ERC721EnumerableMock is ERC721Enumerable {
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function safeMint(address to, uint256 tokenId) external {
        _safeMint(to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ERC721Mock is ERC721 {
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function safeMint(address to, uint256 tokenId) external {
        _safeMint(to, tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/trader/ITraderPool.sol";

contract BundleMock {
    function investDivest(ITraderPool pool, IERC20 token, uint256 amount) external {
        token.approve(address(pool), amount);

        pool.invest(amount, new uint256[](0));
        pool.divest(amount, new uint256[](0), 0);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../trader/TraderPool.sol";

contract TraderPoolMock is TraderPool {
    using EnumerableSet for EnumerableSet.AddressSet;
    using TraderPoolLeverage for PoolParameters;

    function __TraderPoolMock_init(
        string calldata name,
        string calldata symbol,
        PoolParameters calldata _poolParameters
    ) public initializer {
        __TraderPool_init(name, symbol, _poolParameters);
    }

    function proposalPoolAddress() external pure override returns (address) {
        return address(0);
    }

    function totalEmission() public view override returns (uint256) {
        return totalSupply();
    }

    function canRemovePrivateInvestor(address investor) public view override returns (bool) {
        return balanceOf(investor) == 0;
    }

    function isInvestor(address investor) external view returns (bool) {
        return _investors.contains(investor);
    }

    function getMaxTraderLeverage() public view returns (uint256 maxTraderLeverage) {
        (, maxTraderLeverage) = _poolParameters.getMaxTraderLeverage();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/trader/IBasicTraderPool.sol";
import "../interfaces/trader/ITraderPoolRiskyProposal.sol";

import "./TraderPool.sol";

contract BasicTraderPool is IBasicTraderPool, TraderPool {
    using MathHelper for uint256;
    using SafeERC20 for IERC20;

    ITraderPoolRiskyProposal internal _traderPoolProposal;

    event ProposalDivested(
        uint256 proposalId,
        address user,
        uint256 divestedLP2,
        uint256 receivedLP,
        uint256 receivedBase
    );

    modifier onlyProposalPool() {
        _onlyProposalPool();
        _;
    }

    function __BasicTraderPool_init(
        string calldata name,
        string calldata symbol,
        ITraderPool.PoolParameters calldata _poolParameters,
        address traderPoolProposal
    ) public initializer {
        __TraderPool_init(name, symbol, _poolParameters);

        _traderPoolProposal = ITraderPoolRiskyProposal(traderPoolProposal);

        IERC20(_poolParameters.baseToken).safeApprove(traderPoolProposal, MAX_UINT);
    }

    function setDependencies(address contractsRegistry) public override dependant {
        super.setDependencies(contractsRegistry);

        AbstractDependant(address(_traderPoolProposal)).setDependencies(contractsRegistry);
    }

    function exchange(
        address from,
        address to,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ExchangeType exType
    ) public override {
        require(
            to == _poolParameters.baseToken || coreProperties.isWhitelistedToken(to),
            "BTP: invalid exchange"
        );

        super.exchange(from, to, amount, amountBound, optionalPath, exType);
    }

    function createProposal(
        address token,
        uint256 lpAmount,
        ITraderPoolRiskyProposal.ProposalLimits calldata proposalLimits,
        uint256 instantTradePercentage,
        uint256[] calldata minDivestOut,
        uint256 minProposalOut,
        address[] calldata optionalPath
    ) external override onlyTrader {
        uint256 baseAmount = _divestPositions(lpAmount, minDivestOut);

        _traderPoolProposal.create(
            token,
            proposalLimits,
            lpAmount,
            baseAmount,
            instantTradePercentage,
            minProposalOut,
            optionalPath
        );

        _burn(msg.sender, lpAmount);
    }

    function investProposal(
        uint256 proposalId,
        uint256 lpAmount,
        uint256[] calldata minDivestOut,
        uint256 minProposalOut
    ) external override {
        uint256 baseAmount = _divestPositions(lpAmount, minDivestOut);

        _traderPoolProposal.invest(proposalId, msg.sender, lpAmount, baseAmount, minProposalOut);

        _updateFromData(msg.sender, lpAmount);
        _burn(msg.sender, lpAmount);
    }

    function reinvestProposal(
        uint256 proposalId,
        uint256 lp2Amount,
        uint256[] calldata minPositionsOut,
        uint256 minProposalOut
    ) external override {
        uint256 receivedBase = _traderPoolProposal.divest(
            proposalId,
            msg.sender,
            lp2Amount,
            minProposalOut
        );

        uint256 lpMinted = _investPositions(
            address(_traderPoolProposal),
            receivedBase,
            minPositionsOut
        );
        _updateToData(msg.sender, receivedBase);

        emit ProposalDivested(proposalId, msg.sender, lp2Amount, lpMinted, receivedBase);
    }

    function proposalPoolAddress() external view override returns (address) {
        return address(_traderPoolProposal);
    }

    function totalEmission() public view override returns (uint256) {
        return totalSupply() + _traderPoolProposal.totalLockedLP();
    }

    function canRemovePrivateInvestor(address investor) public view override returns (bool) {
        return
            balanceOf(investor) == 0 &&
            _traderPoolProposal.getTotalActiveInvestments(investor) == 0;
    }

    function checkRemoveInvestor(address user) external override onlyProposalPool {
        _checkRemoveInvestor(user, 0);
    }

    function checkNewInvestor(address user) external override onlyProposalPool {
        _checkNewInvestor(user);
    }

    function _onlyProposalPool() internal view {
        require(msg.sender == address(_traderPoolProposal), "BTP: not a proposal");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/trader/IInvestTraderPool.sol";
import "../interfaces/trader/ITraderPoolInvestProposal.sol";

import "./TraderPool.sol";

contract InvestTraderPool is IInvestTraderPool, TraderPool {
    using SafeERC20 for IERC20;
    using MathHelper for uint256;
    using DecimalsConverter for uint256;

    ITraderPoolInvestProposal internal _traderPoolProposal;

    uint256 internal _firstExchange;

    event ProposalDivested(
        uint256 proposalId,
        address user,
        uint256 divestedLP2,
        uint256 receivedLP,
        uint256 receivedBase
    );

    modifier onlyProposalPool() {
        _onlyProposalPool();
        _;
    }

    function __InvestTraderPool_init(
        string calldata name,
        string calldata symbol,
        ITraderPool.PoolParameters calldata _poolParameters,
        address traderPoolProposal
    ) public initializer {
        __TraderPool_init(name, symbol, _poolParameters);

        _traderPoolProposal = ITraderPoolInvestProposal(traderPoolProposal);

        IERC20(_poolParameters.baseToken).safeApprove(traderPoolProposal, MAX_UINT);
    }

    function setDependencies(address contractsRegistry) public override dependant {
        super.setDependencies(contractsRegistry);

        AbstractDependant(address(_traderPoolProposal)).setDependencies(contractsRegistry);
    }

    function invest(
        uint256 amountInBaseToInvest,
        uint256[] calldata minPositionsOut
    ) public override {
        require(
            isTraderAdmin(msg.sender) || getInvestDelayEnd() <= block.timestamp,
            "ITP: investment delay"
        );

        super.invest(amountInBaseToInvest, minPositionsOut);
    }

    function exchange(
        address from,
        address to,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ExchangeType exType
    ) public override {
        _setFirstExchangeTime();

        super.exchange(from, to, amount, amountBound, optionalPath, exType);
    }

    function createProposal(
        string calldata descriptionURL,
        uint256 lpAmount,
        ITraderPoolInvestProposal.ProposalLimits calldata proposalLimits,
        uint256[] calldata minPositionsOut
    ) external override onlyTrader {
        uint256 baseAmount = _divestPositions(lpAmount, minPositionsOut);

        _traderPoolProposal.create(descriptionURL, proposalLimits, lpAmount, baseAmount);

        _burn(msg.sender, lpAmount);
    }

    function investProposal(
        uint256 proposalId,
        uint256 lpAmount,
        uint256[] calldata minPositionsOut
    ) external override {
        require(
            isTraderAdmin(msg.sender) || getInvestDelayEnd() <= block.timestamp,
            "ITP: investment delay"
        );

        uint256 baseAmount = _divestPositions(lpAmount, minPositionsOut);

        _traderPoolProposal.invest(proposalId, msg.sender, lpAmount, baseAmount);

        _updateFromData(msg.sender, lpAmount);
        _burn(msg.sender, lpAmount);
    }

    function reinvestProposal(
        uint256 proposalId,
        uint256[] calldata minPositionsOut
    ) external override {
        uint256 receivedBase = _traderPoolProposal.divest(proposalId, msg.sender);

        if (receivedBase == 0) {
            return;
        }

        uint256 lpMinted = _investPositions(
            address(_traderPoolProposal),
            receivedBase,
            minPositionsOut
        );
        _updateToData(msg.sender, receivedBase);

        emit ProposalDivested(proposalId, msg.sender, 0, lpMinted, receivedBase);
    }

    function proposalPoolAddress() external view override returns (address) {
        return address(_traderPoolProposal);
    }

    function totalEmission() public view override returns (uint256) {
        return totalSupply() + _traderPoolProposal.totalLockedLP();
    }

    function canRemovePrivateInvestor(address investor) public view override returns (bool) {
        return
            balanceOf(investor) == 0 &&
            _traderPoolProposal.getTotalActiveInvestments(investor) == 0;
    }

    function getInvestDelayEnd() public view override returns (uint256) {
        uint256 delay = coreProperties.getDelayForRiskyPool();

        return delay != 0 ? (_firstExchange != 0 ? _firstExchange + delay : MAX_UINT) : 0;
    }

    function checkRemoveInvestor(address user) external override onlyProposalPool {
        _checkRemoveInvestor(user, 0);
    }

    function checkNewInvestor(address user) external override onlyProposalPool {
        _checkNewInvestor(user);
    }

    function _setFirstExchangeTime() internal {
        if (_firstExchange == 0) {
            _firstExchange = block.timestamp;
        }
    }

    function _onlyProposalPool() internal view {
        require(msg.sender == address(_traderPoolProposal), "ITP: not a proposal");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";
import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "../interfaces/trader/ITraderPool.sol";
import "../interfaces/core/IPriceFeed.sol";
import "../interfaces/insurance/IInsurance.sol";
import "../interfaces/core/IContractsRegistry.sol";

import "../libs/price-feed/PriceFeedLocal.sol";
import "../libs/trader-pool/TraderPoolPrice.sol";
import "../libs/trader-pool/TraderPoolLeverage.sol";
import "../libs/trader-pool/TraderPoolCommission.sol";
import "../libs/trader-pool/TraderPoolExchange.sol";
import "../libs/trader-pool/TraderPoolView.sol";
import "../libs/utils/TokenBalance.sol";
import "../libs/math/MathHelper.sol";

import "../core/Globals.sol";

abstract contract TraderPool is ITraderPool, ERC20Upgradeable, AbstractDependant {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    using Math for uint256;
    using DecimalsConverter for uint256;
    using TraderPoolPrice for PoolParameters;
    using TraderPoolPrice for address;
    using TraderPoolLeverage for PoolParameters;
    using TraderPoolCommission for PoolParameters;
    using TraderPoolExchange for PoolParameters;
    using TraderPoolView for PoolParameters;
    using MathHelper for uint256;
    using PriceFeedLocal for IPriceFeed;
    using TokenBalance for address;

    IERC20 internal _dexeToken;
    IPriceFeed public override priceFeed;
    ICoreProperties public override coreProperties;

    EnumerableSet.AddressSet internal _traderAdmins;

    PoolParameters internal _poolParameters;

    EnumerableSet.AddressSet internal _privateInvestors;
    EnumerableSet.AddressSet internal _investors;
    EnumerableSet.AddressSet internal _positions;

    mapping(address => mapping(uint256 => uint256)) internal _investsInBlocks; // user => block => LP amount

    mapping(address => InvestorInfo) public investorsInfo;

    event InvestorAdded(address investor);
    event InvestorRemoved(address investor);
    event Invested(address user, uint256 investedBase, uint256 receivedLP);
    event Divested(address user, uint256 divestedLP, uint256 receivedBase);
    event ActivePortfolioExchanged(
        address fromToken,
        address toToken,
        uint256 fromVolume,
        uint256 toVolume
    );
    event CommissionClaimed(address sender, uint256 traderLpClaimed, uint256 traderBaseClaimed);
    event DescriptionURLChanged(address sender, string descriptionURL);
    event ModifiedAdmins(address sender, address[] admins, bool add);
    event ModifiedPrivateInvestors(address sender, address[] privateInvestors, bool add);

    modifier onlyTraderAdmin() {
        _onlyTraderAdmin();
        _;
    }

    modifier onlyTrader() {
        _onlyTrader();
        _;
    }

    function isPrivateInvestor(address who) public view override returns (bool) {
        return _privateInvestors.contains(who);
    }

    function isTraderAdmin(address who) public view override returns (bool) {
        return _traderAdmins.contains(who);
    }

    function isTrader(address who) public view override returns (bool) {
        return _poolParameters.trader == who;
    }

    function __TraderPool_init(
        string calldata name,
        string calldata symbol,
        PoolParameters calldata poolParameters
    ) public onlyInitializing {
        __ERC20_init(name, symbol);

        _poolParameters = poolParameters;
        _traderAdmins.add(poolParameters.trader);
    }

    function setDependencies(address contractsRegistry) public virtual override dependant {
        IContractsRegistry registry = IContractsRegistry(contractsRegistry);

        _dexeToken = IERC20(registry.getDEXEContract());
        priceFeed = IPriceFeed(registry.getPriceFeedContract());
        coreProperties = ICoreProperties(registry.getCorePropertiesContract());
    }

    function modifyAdmins(address[] calldata admins, bool add) external override onlyTraderAdmin {
        for (uint256 i = 0; i < admins.length; i++) {
            if (add) {
                _traderAdmins.add(admins[i]);
            } else {
                _traderAdmins.remove(admins[i]);
            }
        }

        _traderAdmins.add(_poolParameters.trader);

        emit ModifiedAdmins(msg.sender, admins, add);
    }

    function modifyPrivateInvestors(
        address[] calldata privateInvestors,
        bool add
    ) external override onlyTraderAdmin {
        for (uint256 i = 0; i < privateInvestors.length; i++) {
            if (add) {
                _privateInvestors.add(privateInvestors[i]);
            } else {
                require(
                    canRemovePrivateInvestor(privateInvestors[i]),
                    "TP: can't remove investor"
                );

                _privateInvestors.remove(privateInvestors[i]);
            }
        }

        emit ModifiedPrivateInvestors(msg.sender, privateInvestors, add);
    }

    function changePoolParameters(
        string calldata descriptionURL,
        bool privatePool,
        uint256 totalLPEmission,
        uint256 minimalInvestment
    ) external override onlyTraderAdmin {
        require(
            totalLPEmission == 0 || totalEmission() <= totalLPEmission,
            "TP: wrong emission supply"
        );
        require(
            !privatePool || (privatePool && _investors.length() == 0),
            "TP: pool is not empty"
        );

        _poolParameters.descriptionURL = descriptionURL;
        _poolParameters.privatePool = privatePool;
        _poolParameters.totalLPEmission = totalLPEmission;
        _poolParameters.minimalInvestment = minimalInvestment;

        emit DescriptionURLChanged(msg.sender, descriptionURL);
    }

    function invest(
        uint256 amountInBaseToInvest,
        uint256[] calldata minPositionsOut
    ) public virtual override {
        require(amountInBaseToInvest > 0, "TP: zero investment");
        require(amountInBaseToInvest >= _poolParameters.minimalInvestment, "TP: underinvestment");

        _poolParameters.checkLeverage(amountInBaseToInvest);

        uint256 lpMinted = _investPositions(msg.sender, amountInBaseToInvest, minPositionsOut);
        _updateTo(msg.sender, lpMinted, amountInBaseToInvest);
    }

    function reinvestCommission(
        uint256[] calldata offsetLimits,
        uint256 minDexeCommissionOut
    ) external virtual override onlyTraderAdmin {
        require(openPositions().length == 0, "TP: positions are open");

        uint256 investorsLength = _investors.length();
        uint256 totalSupply = totalSupply();
        uint256 nextCommissionEpoch = getNextCommissionEpoch();
        uint256 allBaseCommission;
        uint256 allLPCommission;

        for (uint256 i = 0; i < offsetLimits.length; i += 2) {
            uint256 to = (offsetLimits[i] + offsetLimits[i + 1]).min(investorsLength).max(
                offsetLimits[i]
            );

            for (uint256 j = offsetLimits[i]; j < to; j++) {
                address investor = _investors.at(j);
                InvestorInfo storage info = investorsInfo[investor];

                if (nextCommissionEpoch > info.commissionUnlockEpoch) {
                    (
                        uint256 investorBaseAmount,
                        uint256 baseCommission,
                        uint256 lpCommission
                    ) = _poolParameters.calculateCommissionOnReinvest(investor, totalSupply);

                    info.commissionUnlockEpoch = nextCommissionEpoch;

                    if (lpCommission > 0) {
                        info.investedBase = investorBaseAmount - baseCommission;

                        _burn(investor, lpCommission);

                        allBaseCommission += baseCommission;
                        allLPCommission += lpCommission;
                    }
                }
            }
        }

        _distributeCommission(allBaseCommission, allLPCommission, minDexeCommissionOut);
    }

    function divest(
        uint256 amountLP,
        uint256[] calldata minPositionsOut,
        uint256 minDexeCommissionOut
    ) public virtual override {
        bool senderTrader = isTrader(msg.sender);
        require(!senderTrader || openPositions().length == 0, "TP: can't divest");

        if (senderTrader) {
            _divestTrader(amountLP);
        } else {
            _divestInvestor(amountLP, minPositionsOut, minDexeCommissionOut);
        }
    }

    function exchange(
        address from,
        address to,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ExchangeType exType
    ) public virtual override onlyTraderAdmin {
        _poolParameters.exchange(_positions, from, to, amount, amountBound, optionalPath, exType);
    }

    function proposalPoolAddress() external view virtual override returns (address);

    function totalEmission() public view virtual override returns (uint256);

    function canRemovePrivateInvestor(
        address investor
    ) public view virtual override returns (bool);

    function totalInvestors() external view override returns (uint256) {
        return _investors.length();
    }

    function openPositions() public view returns (address[] memory) {
        return coreProperties.getFilteredPositions(_positions.values());
    }

    function getUsersInfo(
        address user,
        uint256 offset,
        uint256 limit
    ) external view override returns (UserInfo[] memory usersInfo) {
        return _poolParameters.getUsersInfo(_investors, user, offset, limit);
    }

    function getPoolInfo() external view override returns (PoolInfo memory poolInfo) {
        return _poolParameters.getPoolInfo(_positions);
    }

    function getLeverageInfo() external view override returns (LeverageInfo memory leverageInfo) {
        return _poolParameters.getLeverageInfo();
    }

    function getInvestTokens(
        uint256 amountInBaseToInvest
    ) external view override returns (Receptions memory receptions) {
        return _poolParameters.getInvestTokens(amountInBaseToInvest);
    }

    function getReinvestCommissions(
        uint256[] calldata offsetLimits
    ) external view override returns (Commissions memory commissions) {
        return _poolParameters.getReinvestCommissions(_investors, offsetLimits);
    }

    function getNextCommissionEpoch() public view override returns (uint256) {
        return _poolParameters.nextCommissionEpoch();
    }

    function getDivestAmountsAndCommissions(
        address user,
        uint256 amountLP
    )
        external
        view
        override
        returns (Receptions memory receptions, Commissions memory commissions)
    {
        return _poolParameters.getDivestAmountsAndCommissions(user, amountLP);
    }

    function getExchangeAmount(
        address from,
        address to,
        uint256 amount,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external view override returns (uint256, address[] memory) {
        return
            _poolParameters.getExchangeAmount(_positions, from, to, amount, optionalPath, exType);
    }

    function _transferBaseAndMintLP(
        address baseHolder,
        uint256 totalBaseInPool,
        uint256 amountInBaseToInvest
    ) internal returns (uint256) {
        IERC20(_poolParameters.baseToken).safeTransferFrom(
            baseHolder,
            address(this),
            amountInBaseToInvest.from18(_poolParameters.baseTokenDecimals)
        );

        uint256 toMintLP = amountInBaseToInvest;

        if (totalBaseInPool > 0) {
            toMintLP = toMintLP.ratio(totalSupply(), totalBaseInPool);
        }

        require(
            _poolParameters.totalLPEmission == 0 ||
                totalEmission() + toMintLP <= _poolParameters.totalLPEmission,
            "TP: minting > emission"
        );

        _investsInBlocks[msg.sender][block.number] += toMintLP;
        _mint(msg.sender, toMintLP);

        return toMintLP;
    }

    function _investPositions(
        address baseHolder,
        uint256 amountInBaseToInvest,
        uint256[] calldata minPositionsOut
    ) internal returns (uint256 lpMinted) {
        address baseToken = _poolParameters.baseToken;
        (
            uint256 totalBase,
            ,
            address[] memory positionTokens,
            uint256[] memory positionPricesInBase
        ) = _poolParameters.getNormalizedPoolPriceAndPositions();

        lpMinted = _transferBaseAndMintLP(baseHolder, totalBase, amountInBaseToInvest);

        for (uint256 i = 0; i < positionTokens.length; i++) {
            uint256 amount = positionPricesInBase[i].ratio(amountInBaseToInvest, totalBase);
            uint256 amountGot = priceFeed.normExchangeFromExact(
                baseToken,
                positionTokens[i],
                amount,
                new address[](0),
                minPositionsOut[i]
            );

            emit ActivePortfolioExchanged(baseToken, positionTokens[i], amount, amountGot);
        }
    }

    function _distributeCommission(
        uint256 baseToDistribute,
        uint256 lpToDistribute,
        uint256 minDexeCommissionOut
    ) internal {
        require(baseToDistribute > 0, "TP: no commission available");

        (
            uint256 dexePercentage,
            ,
            uint256[] memory poolPercentages,
            address[3] memory commissionReceivers
        ) = coreProperties.getDEXECommissionPercentages();

        (uint256 dexeLPCommission, uint256 dexeBaseCommission) = TraderPoolCommission
            .calculateDexeCommission(baseToDistribute, lpToDistribute, dexePercentage);
        uint256 dexeCommission = priceFeed.normExchangeFromExact(
            _poolParameters.baseToken,
            address(_dexeToken),
            dexeBaseCommission,
            new address[](0),
            minDexeCommissionOut
        );

        _mint(_poolParameters.trader, lpToDistribute - dexeLPCommission);
        TraderPoolCommission.sendDexeCommission(
            _dexeToken,
            dexeCommission,
            poolPercentages,
            commissionReceivers
        );

        emit CommissionClaimed(
            msg.sender,
            lpToDistribute - dexeLPCommission,
            baseToDistribute - dexeBaseCommission
        );
    }

    function _divestPositions(
        uint256 amountLP,
        uint256[] calldata minPositionsOut
    ) internal returns (uint256 investorBaseAmount) {
        _checkUserBalance(amountLP);

        address[] memory _openPositions = openPositions();
        address baseToken = _poolParameters.baseToken;
        uint256 totalSupply = totalSupply();

        investorBaseAmount = baseToken.normThisBalance().ratio(amountLP, totalSupply);

        for (uint256 i = 0; i < _openPositions.length; i++) {
            uint256 amount = _openPositions[i].normThisBalance().ratio(amountLP, totalSupply);
            uint256 amountGot = priceFeed.normExchangeFromExact(
                _openPositions[i],
                baseToken,
                amount,
                new address[](0),
                minPositionsOut[i]
            );

            investorBaseAmount += amountGot;

            emit ActivePortfolioExchanged(_openPositions[i], baseToken, amount, amountGot);
        }
    }

    function _divestInvestor(
        uint256 amountLP,
        uint256[] calldata minPositionsOut,
        uint256 minDexeCommissionOut
    ) internal {
        uint256 investorBaseAmount = _divestPositions(amountLP, minPositionsOut);
        (uint256 baseCommission, uint256 lpCommission) = _poolParameters
            .calculateCommissionOnDivest(msg.sender, investorBaseAmount, amountLP);
        uint256 receivedBase = investorBaseAmount - baseCommission;

        _updateFrom(msg.sender, amountLP, receivedBase);
        _burn(msg.sender, amountLP);

        IERC20(_poolParameters.baseToken).safeTransfer(
            msg.sender,
            receivedBase.from18(_poolParameters.baseTokenDecimals)
        );

        if (baseCommission > 0) {
            _distributeCommission(baseCommission, lpCommission, minDexeCommissionOut);
        }
    }

    function _divestTrader(uint256 amountLP) internal {
        _checkUserBalance(amountLP);

        IERC20 baseToken = IERC20(_poolParameters.baseToken);
        uint256 receivedBase = address(baseToken).normThisBalance().ratio(amountLP, totalSupply());

        _updateFrom(msg.sender, amountLP, receivedBase);
        _burn(msg.sender, amountLP);

        baseToken.safeTransfer(msg.sender, receivedBase.from18(_poolParameters.baseTokenDecimals));
    }

    function _updateFromData(
        address user,
        uint256 lpAmount
    ) internal returns (uint256 baseTransfer) {
        if (!isTrader(user)) {
            InvestorInfo storage info = investorsInfo[user];

            baseTransfer = info.investedBase.ratio(lpAmount, balanceOf(user));
            info.investedBase -= baseTransfer;
        }
    }

    function _updateToData(address user, uint256 baseAmount) internal {
        if (!isTrader(user)) {
            investorsInfo[user].investedBase += baseAmount;
        }
    }

    function _checkRemoveInvestor(address user, uint256 lpAmount) internal {
        if (!isTrader(user) && lpAmount == balanceOf(user)) {
            _investors.remove(user);
            investorsInfo[user].commissionUnlockEpoch = 0;

            emit InvestorRemoved(user);
        }
    }

    function _checkNewInvestor(address user) internal {
        require(
            !_poolParameters.privatePool || isTraderAdmin(user) || isPrivateInvestor(user),
            "TP: private pool"
        );

        if (!isTrader(user) && !_investors.contains(user)) {
            _investors.add(user);
            investorsInfo[user].commissionUnlockEpoch = getNextCommissionEpoch();

            require(
                _investors.length() <= coreProperties.getMaximumPoolInvestors(),
                "TP: max investors"
            );

            emit InvestorAdded(user);
        }
    }

    function _updateFrom(
        address user,
        uint256 lpAmount,
        uint256 baseAmount
    ) internal returns (uint256 baseTransfer) {
        baseTransfer = _updateFromData(user, lpAmount);

        emit Divested(user, lpAmount, baseAmount == 0 ? baseTransfer : baseAmount);

        _checkRemoveInvestor(user, lpAmount);
    }

    function _updateTo(address user, uint256 lpAmount, uint256 baseAmount) internal {
        _checkNewInvestor(user);
        _updateToData(user, baseAmount);

        emit Invested(user, baseAmount, lpAmount);
    }

    /// @notice if trader transfers tokens to an investor, we will count them as "earned" and add to the commission calculation
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(amount > 0, "TP: 0 transfer");

        if (from != address(0) && to != address(0) && from != to) {
            uint256 baseTransfer = _updateFrom(from, amount, 0); // baseTransfer is intended to be zero if sender is a trader
            _updateTo(to, amount, baseTransfer);
        }
    }

    function _onlyTraderAdmin() internal view {
        require(isTraderAdmin(msg.sender), "TP: not an admin");
    }

    function _onlyTrader() internal view {
        require(isTrader(msg.sender), "TP: not a trader");
    }

    function _checkUserBalance(uint256 amountLP) internal view {
        require(
            amountLP <= balanceOf(msg.sender) - _investsInBlocks[msg.sender][block.number],
            "TP: wrong amount"
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../interfaces/trader/ITraderPoolInvestProposal.sol";
import "../interfaces/trader/IInvestTraderPool.sol";

import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";
import "@dlsl/dev-modules/libs/arrays/ArrayHelper.sol";

import "../libs/trader-pool-proposal/TraderPoolInvestProposalView.sol";

import "../core/Globals.sol";
import "./TraderPoolProposal.sol";

contract TraderPoolInvestProposal is ITraderPoolInvestProposal, TraderPoolProposal {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using DecimalsConverter for uint256;
    using MathHelper for uint256;
    using Math for uint256;
    using TraderPoolInvestProposalView for ParentTraderPoolInfo;

    mapping(uint256 => ProposalInfo) internal _proposalInfos; // proposal id => info
    mapping(uint256 => RewardInfo) internal _rewardInfos; // proposal id => reward info

    mapping(address => mapping(uint256 => UserRewardInfo)) internal _userRewardInfos; // user => proposal id => user reward info

    event ProposalCreated(
        uint256 proposalId,
        ITraderPoolInvestProposal.ProposalLimits proposalLimits
    );
    event ProposalWithdrawn(uint256 proposalId, address sender, uint256 amount);
    event ProposalSupplied(
        uint256 proposalId,
        address sender,
        uint256[] amounts,
        address[] tokens
    );
    event ProposalClaimed(uint256 proposalId, address user, uint256[] amounts, address[] tokens);
    event ProposalConverted(uint256 proposalId, address user, uint256 amount, address baseToken);

    function __TraderPoolInvestProposal_init(
        ParentTraderPoolInfo calldata parentTraderPoolInfo
    ) public initializer {
        __TraderPoolProposal_init(parentTraderPoolInfo);
    }

    function changeProposalRestrictions(
        uint256 proposalId,
        ProposalLimits calldata proposalLimits
    ) external override onlyTraderAdmin {
        require(proposalId <= proposalsTotalNum, "TPIP: proposal doesn't exist");

        _proposalInfos[proposalId].proposalLimits = proposalLimits;

        emit ProposalRestrictionsChanged(proposalId, msg.sender);
    }

    function create(
        string calldata descriptionURL,
        ProposalLimits calldata proposalLimits,
        uint256 lpInvestment,
        uint256 baseInvestment
    ) external override onlyParentTraderPool returns (uint256 proposalId) {
        require(
            proposalLimits.timestampLimit == 0 || proposalLimits.timestampLimit >= block.timestamp,
            "TPIP: wrong timestamp"
        );
        require(
            proposalLimits.investLPLimit == 0 || proposalLimits.investLPLimit >= lpInvestment,
            "TPIP: wrong investment limit"
        );
        require(lpInvestment > 0 && baseInvestment > 0, "TPIP: zero investment");

        proposalId = ++proposalsTotalNum;

        address trader = _parentTraderPoolInfo.trader;

        _proposalInfos[proposalId].proposalLimits = proposalLimits;

        emit ProposalCreated(proposalId, proposalLimits);

        _transferAndMintLP(proposalId, trader, lpInvestment, baseInvestment);

        _proposalInfos[proposalId].descriptionURL = descriptionURL;
        _proposalInfos[proposalId].lpLocked = lpInvestment;
        _proposalInfos[proposalId].investedBase = baseInvestment;
        _proposalInfos[proposalId].newInvestedBase = baseInvestment;
    }

    function invest(
        uint256 proposalId,
        address user,
        uint256 lpInvestment,
        uint256 baseInvestment
    ) external override onlyParentTraderPool {
        require(proposalId <= proposalsTotalNum, "TPIP: proposal doesn't exist");

        ProposalInfo storage info = _proposalInfos[proposalId];

        require(
            info.proposalLimits.timestampLimit == 0 ||
                block.timestamp <= info.proposalLimits.timestampLimit,
            "TPIP: proposal is closed"
        );
        require(
            info.proposalLimits.investLPLimit == 0 ||
                info.lpLocked + lpInvestment <= info.proposalLimits.investLPLimit,
            "TPIP: proposal is overinvested"
        );

        _updateRewards(proposalId, user);
        _transferAndMintLP(proposalId, user, lpInvestment, baseInvestment);

        info.lpLocked += lpInvestment;
        info.investedBase += baseInvestment;
        info.newInvestedBase += baseInvestment;
    }

    function divest(
        uint256 proposalId,
        address user
    ) external override onlyParentTraderPool returns (uint256 claimedBase) {
        require(proposalId <= proposalsTotalNum, "TPIP: proposal doesn't exist");

        (
            uint256 totalClaimed,
            uint256[] memory claimed,
            address[] memory addresses
        ) = _calculateRewards(proposalId, user);

        require(totalClaimed > 0, "TPIP: nothing to divest");

        emit ProposalClaimed(proposalId, user, claimed, addresses);

        if (addresses[0] == _parentTraderPoolInfo.baseToken) {
            claimedBase = claimed[0];
            addresses[0] = address(0);

            _proposalInfos[proposalId].lpLocked -= claimed[0].min(
                _proposalInfos[proposalId].lpLocked
            );

            _updateFromData(user, proposalId, claimed[0]);
            investedBase -= claimed[0].min(investedBase);
            totalLockedLP -= claimed[0].min(totalLockedLP); // intentional base from LP subtraction
        }

        _payout(user, claimed, addresses);
    }

    function withdraw(uint256 proposalId, uint256 amount) external override onlyTraderAdmin {
        require(proposalId <= proposalsTotalNum, "TPIP: proposal doesn't exist");
        require(
            amount <= _proposalInfos[proposalId].newInvestedBase,
            "TPIP: withdrawing more than balance"
        );

        _proposalInfos[proposalId].newInvestedBase -= amount;

        IERC20(_parentTraderPoolInfo.baseToken).safeTransfer(
            _parentTraderPoolInfo.trader,
            amount.from18(_parentTraderPoolInfo.baseTokenDecimals)
        );

        emit ProposalWithdrawn(proposalId, msg.sender, amount);
    }

    function supply(
        uint256 proposalId,
        uint256[] calldata amounts,
        address[] calldata addresses
    ) external override onlyTraderAdmin {
        require(proposalId <= proposalsTotalNum, "TPIP: proposal doesn't exist");
        require(addresses.length == amounts.length, "TPIP: length mismatch");

        for (uint256 i = 0; i < addresses.length; i++) {
            address token = addresses[i];
            uint256 actualAmount = amounts[i].from18(ERC20(token).decimals());

            require(actualAmount > 0, "TPIP: amount is 0");

            IERC20(token).safeTransferFrom(msg.sender, address(this), actualAmount);

            _updateCumulativeSum(proposalId, amounts[i], token);
        }

        emit ProposalSupplied(proposalId, msg.sender, amounts, addresses);
    }

    function convertInvestedBaseToDividends(uint256 proposalId) external override onlyTraderAdmin {
        require(proposalId <= proposalsTotalNum, "TPIP: proposal doesn't exist");

        uint256 newInvestedBase = _proposalInfos[proposalId].newInvestedBase;
        address baseToken = _parentTraderPoolInfo.baseToken;

        _updateCumulativeSum(proposalId, newInvestedBase, baseToken);

        delete _proposalInfos[proposalId].newInvestedBase;

        emit ProposalConverted(proposalId, msg.sender, newInvestedBase, baseToken);
    }

    function getProposalInfos(
        uint256 offset,
        uint256 limit
    ) external view override returns (ProposalInfoExtended[] memory proposals) {
        return
            TraderPoolInvestProposalView.getProposalInfos(
                _proposalInfos,
                _investors,
                offset,
                limit
            );
    }

    function getActiveInvestmentsInfo(
        address user,
        uint256 offset,
        uint256 limit
    ) external view override returns (ActiveInvestmentInfo[] memory investments) {
        return
            TraderPoolInvestProposalView.getActiveInvestmentsInfo(
                _activeInvestments[user],
                _baseBalances,
                _lpBalances,
                user,
                offset,
                limit
            );
    }

    function getRewards(
        uint256[] calldata proposalIds,
        address user
    ) external view override returns (Receptions memory receptions) {
        return
            TraderPoolInvestProposalView.getRewards(
                _rewardInfos,
                _userRewardInfos,
                proposalIds,
                user
            );
    }

    function _updateCumulativeSum(uint256 proposalId, uint256 amount, address token) internal {
        RewardInfo storage rewardInfo = _rewardInfos[proposalId];

        rewardInfo.rewardTokens.add(token);
        rewardInfo.cumulativeSums[token] += PRECISION.ratio(amount, totalSupply(proposalId));
    }

    function _updateRewards(uint256 proposalId, address user) internal {
        UserRewardInfo storage userRewardInfo = _userRewardInfos[user][proposalId];
        RewardInfo storage rewardInfo = _rewardInfos[proposalId];

        uint256 length = rewardInfo.rewardTokens.length();

        for (uint256 i = 0; i < length; i++) {
            address token = rewardInfo.rewardTokens.at(i);
            uint256 cumulativeSum = rewardInfo.cumulativeSums[token];

            userRewardInfo.rewardsStored[token] +=
                ((cumulativeSum - userRewardInfo.cumulativeSumsStored[token]) *
                    balanceOf(user, proposalId)) /
                PRECISION;
            userRewardInfo.cumulativeSumsStored[token] = cumulativeSum;
        }
    }

    function _calculateRewards(
        uint256 proposalId,
        address user
    )
        internal
        returns (uint256 totalClaimed, uint256[] memory claimed, address[] memory addresses)
    {
        _updateRewards(proposalId, user);

        RewardInfo storage rewardInfo = _rewardInfos[proposalId];
        uint256 length = rewardInfo.rewardTokens.length();

        claimed = new uint256[](length);
        addresses = new address[](length);

        address baseToken = _parentTraderPoolInfo.baseToken;
        uint256 baseIndex;

        for (uint256 i = 0; i < length; i++) {
            address token = rewardInfo.rewardTokens.at(i);

            claimed[i] = _userRewardInfos[user][proposalId].rewardsStored[token];
            addresses[i] = token;
            totalClaimed += claimed[i];

            delete _userRewardInfos[user][proposalId].rewardsStored[token];

            if (token == baseToken) {
                baseIndex = i;
            }
        }

        if (length > 0) {
            /// @dev make the base token first (if not found, do nothing)
            (claimed[0], claimed[baseIndex]) = (claimed[baseIndex], claimed[0]);
            (addresses[0], addresses[baseIndex]) = (addresses[baseIndex], addresses[0]);
        }
    }

    function _payout(address user, uint256[] memory claimed, address[] memory addresses) internal {
        for (uint256 i = 0; i < addresses.length; i++) {
            address token = addresses[i];

            if (token == address(0)) {
                continue;
            }

            IERC20(token).safeTransfer(user, claimed[i].from18(ERC20(token).decimals()));
        }
    }

    function _updateFrom(
        address user,
        uint256 proposalId,
        uint256 lp2Amount,
        bool isTransfer
    ) internal override returns (uint256 lpTransfer, uint256 baseTransfer) {
        _updateRewards(proposalId, user);

        return super._updateFrom(user, proposalId, lp2Amount, isTransfer);
    }

    function _updateTo(
        address user,
        uint256 proposalId,
        uint256 lp2Amount,
        uint256 lpAmount,
        uint256 baseAmount
    ) internal override {
        _updateRewards(proposalId, user);

        super._updateTo(user, proposalId, lp2Amount, lpAmount, baseAmount);
    }

    function _baseInProposal(uint256 proposalId) internal view override returns (uint256) {
        return _proposalInfos[proposalId].investedBase;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@dlsl/dev-modules/contracts-registry/AbstractDependant.sol";
import "@dlsl/dev-modules/libs/decimals/DecimalsConverter.sol";

import "../interfaces/core/IPriceFeed.sol";
import "../interfaces/trader/ITraderPoolProposal.sol";
import "../interfaces/trader/ITraderPoolInvestorsHook.sol";
import "../interfaces/core/IContractsRegistry.sol";

import "../libs/math/MathHelper.sol";

import "./TraderPool.sol";

abstract contract TraderPoolProposal is
    ITraderPoolProposal,
    ERC1155SupplyUpgradeable,
    AbstractDependant
{
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using MathHelper for uint256;
    using DecimalsConverter for uint256;
    using Math for uint256;

    ParentTraderPoolInfo internal _parentTraderPoolInfo;

    IPriceFeed public override priceFeed;

    uint256 public proposalsTotalNum;

    uint256 public override totalLockedLP;
    uint256 public override investedBase;

    mapping(uint256 => EnumerableSet.AddressSet) internal _investors; // proposal id => investors

    mapping(address => EnumerableSet.UintSet) internal _activeInvestments; // user => proposals
    mapping(address => mapping(uint256 => uint256)) internal _baseBalances; // user => proposal id => base invested
    mapping(address => mapping(uint256 => uint256)) internal _lpBalances; // user => proposal id => LP invested
    mapping(address => uint256) public override totalLPBalances; // user => LP invested

    event ProposalRestrictionsChanged(uint256 proposalId, address sender);
    event ProposalInvestorAdded(uint256 proposalId, address investor);
    event ProposalInvestorRemoved(uint256 proposalId, address investor);
    event ProposalInvested(
        uint256 proposalId,
        address user,
        uint256 investedLP,
        uint256 investedBase,
        uint256 receivedLP2
    );
    event ProposalDivested(
        uint256 proposalId,
        address user,
        uint256 divestedLP2,
        uint256 receivedLP,
        uint256 receivedBase
    );

    modifier onlyParentTraderPool() {
        _onlyParentTraderPool();
        _;
    }

    modifier onlyTraderAdmin() {
        _onlyTraderAdmin();
        _;
    }

    function __TraderPoolProposal_init(
        ParentTraderPoolInfo calldata parentTraderPoolInfo
    ) public onlyInitializing {
        __ERC1155Supply_init();

        _parentTraderPoolInfo = parentTraderPoolInfo;

        IERC20(parentTraderPoolInfo.baseToken).safeApprove(
            parentTraderPoolInfo.parentPoolAddress,
            MAX_UINT
        );
    }

    function setDependencies(address contractsRegistry) external override dependant {
        IContractsRegistry registry = IContractsRegistry(contractsRegistry);

        priceFeed = IPriceFeed(registry.getPriceFeedContract());
    }

    function getBaseToken() external view override returns (address) {
        return _parentTraderPoolInfo.baseToken;
    }

    function getInvestedBaseInUSD() external view override returns (uint256 investedBaseUSD) {
        (investedBaseUSD, ) = priceFeed.getNormalizedPriceOutUSD(
            _parentTraderPoolInfo.baseToken,
            investedBase
        );
    }

    function getTotalActiveInvestments(address user) external view override returns (uint256) {
        return _activeInvestments[user].length();
    }

    function _transferAndMintLP(
        uint256 proposalId,
        address to,
        uint256 lpInvestment,
        uint256 baseInvestment
    ) internal {
        IERC20(_parentTraderPoolInfo.baseToken).safeTransferFrom(
            _parentTraderPoolInfo.parentPoolAddress,
            address(this),
            baseInvestment.from18(_parentTraderPoolInfo.baseTokenDecimals)
        );

        uint256 baseInProposal = _baseInProposal(proposalId);
        uint256 toMint = baseInvestment;

        if (baseInProposal > 0) {
            toMint = toMint.ratio(totalSupply(proposalId), baseInProposal);
        }

        totalLockedLP += lpInvestment;
        investedBase += baseInvestment;

        _mint(to, proposalId, toMint, "");
        _updateTo(to, proposalId, toMint, lpInvestment, baseInvestment);
    }

    function _updateFromData(
        address user,
        uint256 proposalId,
        uint256 lp2Amount
    ) internal returns (uint256 lpTransfer, uint256 baseTransfer) {
        uint256 baseBalance = _baseBalances[user][proposalId];
        uint256 lpBalance = _lpBalances[user][proposalId];

        baseTransfer = baseBalance.ratio(lp2Amount, balanceOf(user, proposalId)).min(baseBalance);
        lpTransfer = lpBalance.ratio(lp2Amount, balanceOf(user, proposalId)).min(lpBalance);

        _baseBalances[user][proposalId] -= baseTransfer;
        _lpBalances[user][proposalId] -= lpTransfer;
        totalLPBalances[user] -= lpTransfer;
    }

    function _updateToData(
        address user,
        uint256 proposalId,
        uint256 lpAmount,
        uint256 baseAmount
    ) internal {
        _activeInvestments[user].add(proposalId);

        _baseBalances[user][proposalId] += baseAmount;
        _lpBalances[user][proposalId] += lpAmount;
        totalLPBalances[user] += lpAmount;
    }

    function _checkRemoveInvestor(address user, uint256 proposalId, uint256 lp2Amount) internal {
        if (balanceOf(user, proposalId) == lp2Amount) {
            _activeInvestments[user].remove(proposalId);

            if (user != _parentTraderPoolInfo.trader) {
                _investors[proposalId].remove(user);

                if (_activeInvestments[user].length() == 0) {
                    ITraderPoolInvestorsHook(_parentTraderPoolInfo.parentPoolAddress)
                        .checkRemoveInvestor(user);
                }

                emit ProposalInvestorRemoved(proposalId, user);
            }
        }
    }

    function _checkNewInvestor(address user, uint256 proposalId) internal {
        if (user != _parentTraderPoolInfo.trader && !_investors[proposalId].contains(user)) {
            _investors[proposalId].add(user);
            ITraderPoolInvestorsHook(_parentTraderPoolInfo.parentPoolAddress).checkNewInvestor(
                user
            );

            emit ProposalInvestorAdded(proposalId, user);
        }
    }

    function _updateFrom(
        address user,
        uint256 proposalId,
        uint256 lp2Amount,
        bool isTransfer
    ) internal virtual returns (uint256 lpTransfer, uint256 baseTransfer) {
        (lpTransfer, baseTransfer) = _updateFromData(user, proposalId, lp2Amount);

        if (isTransfer) {
            emit ProposalDivested(proposalId, user, lp2Amount, lpTransfer, baseTransfer);
        }

        _checkRemoveInvestor(user, proposalId, lp2Amount);
    }

    function _updateTo(
        address user,
        uint256 proposalId,
        uint256 lp2Amount,
        uint256 lpAmount,
        uint256 baseAmount
    ) internal virtual {
        _checkNewInvestor(user, proposalId);
        _updateToData(user, proposalId, lpAmount, baseAmount);

        emit ProposalInvested(proposalId, user, lpAmount, baseAmount, lp2Amount);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < amounts.length; i++) {
            require(amounts[i] > 0, "TPP: 0 transfer");

            if (from != address(0) && to != address(0) && to != from) {
                (uint256 lpTransfer, uint256 baseTransfer) = _updateFrom(
                    from,
                    ids[i],
                    amounts[i],
                    true
                );
                _updateTo(to, ids[i], amounts[i], lpTransfer, baseTransfer);
            }
        }
    }

    function _baseInProposal(uint256 proposalId) internal view virtual returns (uint256);

    function _onlyParentTraderPool() internal view {
        require(msg.sender == _parentTraderPoolInfo.parentPoolAddress, "TPP: not a ParentPool");
    }

    function _onlyTraderAdmin() internal view {
        require(
            TraderPool(_parentTraderPoolInfo.parentPoolAddress).isTraderAdmin(msg.sender),
            "TPP: not a trader admin"
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "../interfaces/trader/ITraderPoolRiskyProposal.sol";
import "../interfaces/trader/IBasicTraderPool.sol";

import "../libs/price-feed/PriceFeedLocal.sol";
import "../libs/trader-pool-proposal/TraderPoolRiskyProposalView.sol";

import "../core/Globals.sol";
import "./TraderPoolProposal.sol";

contract TraderPoolRiskyProposal is ITraderPoolRiskyProposal, TraderPoolProposal {
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;
    using DecimalsConverter for uint256;
    using MathHelper for uint256;
    using Math for uint256;
    using Address for address;
    using TraderPoolRiskyProposalView for ParentTraderPoolInfo;
    using PriceFeedLocal for IPriceFeed;

    mapping(uint256 => ProposalInfo) internal _proposalInfos; // proposal id => info

    event ProposalCreated(
        uint256 proposalId,
        address token,
        ITraderPoolRiskyProposal.ProposalLimits proposalLimits
    );
    event ProposalExchanged(
        uint256 proposalId,
        address sender,
        address fromToken,
        address toToken,
        uint256 fromVolume,
        uint256 toVolume
    );
    event ProposalActivePortfolioExchanged(
        uint256 proposalId,
        address fromToken,
        address toToken,
        uint256 fromVolume,
        uint256 toVolume
    );
    event ProposalPositionClosed(uint256 proposalId, address positionToken);

    function __TraderPoolRiskyProposal_init(
        ParentTraderPoolInfo calldata parentTraderPoolInfo
    ) public initializer {
        __TraderPoolProposal_init(parentTraderPoolInfo);
    }

    function changeProposalRestrictions(
        uint256 proposalId,
        ProposalLimits calldata proposalLimits
    ) external override onlyTraderAdmin {
        require(proposalId <= proposalsTotalNum, "TPRP: proposal doesn't exist");

        _proposalInfos[proposalId].proposalLimits = proposalLimits;

        emit ProposalRestrictionsChanged(proposalId, msg.sender);
    }

    function create(
        address token,
        ProposalLimits calldata proposalLimits,
        uint256 lpInvestment,
        uint256 baseInvestment,
        uint256 instantTradePercentage,
        uint256 minPositionOut,
        address[] calldata optionalPath
    ) external override onlyParentTraderPool returns (uint256 proposalId) {
        require(token.isContract(), "TPRP: not a contract");
        require(token != _parentTraderPoolInfo.baseToken, "TPRP: wrong proposal token");
        require(
            proposalLimits.timestampLimit == 0 || proposalLimits.timestampLimit >= block.timestamp,
            "TPRP: wrong timestamp"
        );
        require(
            proposalLimits.investLPLimit == 0 || proposalLimits.investLPLimit >= lpInvestment,
            "TPRP: wrong investment limit"
        );
        require(lpInvestment > 0 && baseInvestment > 0, "TPRP: zero investment");
        require(instantTradePercentage <= PERCENTAGE_100, "TPRP: percantage is bigger than 100");

        proposalId = ++proposalsTotalNum;

        address baseToken = _parentTraderPoolInfo.baseToken;
        address trader = _parentTraderPoolInfo.trader;

        priceFeed.checkAllowance(baseToken);
        priceFeed.checkAllowance(token);

        _proposalInfos[proposalId].token = token;
        _proposalInfos[proposalId].tokenDecimals = ERC20(token).decimals();
        _proposalInfos[proposalId].proposalLimits = proposalLimits;

        emit ProposalCreated(proposalId, token, proposalLimits);

        _transferAndMintLP(proposalId, trader, lpInvestment, baseInvestment);
        _investActivePortfolio(
            proposalId,
            baseInvestment,
            baseInvestment.percentage(instantTradePercentage),
            lpInvestment,
            optionalPath,
            minPositionOut
        );
    }

    function invest(
        uint256 proposalId,
        address user,
        uint256 lpInvestment,
        uint256 baseInvestment,
        uint256 minPositionOut
    ) external override onlyParentTraderPool {
        require(proposalId <= proposalsTotalNum, "TPRP: proposal doesn't exist");

        ProposalInfo storage info = _proposalInfos[proposalId];

        require(
            info.proposalLimits.timestampLimit == 0 ||
                block.timestamp <= info.proposalLimits.timestampLimit,
            "TPRP: proposal is closed"
        );
        require(
            info.proposalLimits.investLPLimit == 0 ||
                info.lpLocked + lpInvestment <= info.proposalLimits.investLPLimit,
            "TPRP: proposal is overinvested"
        );
        require(
            info.proposalLimits.maxTokenPriceLimit == 0 ||
                priceFeed.getNormPriceIn(_parentTraderPoolInfo.baseToken, info.token, DECIMALS) <=
                info.proposalLimits.maxTokenPriceLimit,
            "TPRP: token price too high"
        );

        address trader = _parentTraderPoolInfo.trader;

        if (user != trader) {
            uint256 traderPercentage = getInvestmentPercentage(proposalId, trader, 0);
            uint256 userPercentage = getInvestmentPercentage(proposalId, user, lpInvestment);

            require(userPercentage <= traderPercentage, "TPRP: investing more than trader");
        }

        _transferAndMintLP(proposalId, user, lpInvestment, baseInvestment);

        if (info.balancePosition + info.balanceBase > 0) {
            uint256 positionTokens = priceFeed.getNormPriceOut(
                info.token,
                _parentTraderPoolInfo.baseToken,
                info.balancePosition
            );
            uint256 baseToExchange = baseInvestment.ratio(
                positionTokens,
                positionTokens + info.balanceBase
            );

            _investActivePortfolio(
                proposalId,
                baseInvestment,
                baseToExchange,
                lpInvestment,
                new address[](0),
                minPositionOut
            );
        }
    }

    function divest(
        uint256 proposalId,
        address user,
        uint256 lp2,
        uint256 minPositionOut
    ) public override onlyParentTraderPool returns (uint256 receivedBase) {
        require(proposalId <= proposalsTotalNum, "TPRP: proposal doesn't exist");
        require(balanceOf(user, proposalId) >= lp2, "TPRP: divesting more than balance");

        if (user == _parentTraderPoolInfo.trader) {
            receivedBase = _divestProposalTrader(proposalId, lp2);
        } else {
            receivedBase = _divestActivePortfolio(proposalId, lp2, minPositionOut);
        }

        (uint256 lpToBurn, uint256 baseToBurn) = _updateFrom(user, proposalId, lp2, false);
        _burn(user, proposalId, lp2);

        _proposalInfos[proposalId].lpLocked -= lpToBurn;

        totalLockedLP -= lpToBurn;
        investedBase -= baseToBurn;
    }

    function exchange(
        uint256 proposalId,
        address from,
        uint256 amount,
        uint256 amountBound,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external override onlyTraderAdmin {
        require(proposalId <= proposalsTotalNum, "TPRP: proposal doesn't exist");

        ProposalInfo storage info = _proposalInfos[proposalId];

        address baseToken = _parentTraderPoolInfo.baseToken;
        address positionToken = info.token;
        address to;

        require(from == baseToken || from == positionToken, "TPRP: invalid from token");

        if (from == baseToken) {
            to = positionToken;
        } else {
            to = baseToken;
        }

        uint256 amountGot;

        if (exType == ITraderPoolRiskyProposal.ExchangeType.FROM_EXACT) {
            if (from == baseToken) {
                require(amount <= info.balanceBase, "TPRP: wrong base amount");
            } else {
                require(amount <= info.balancePosition, "TPRP: wrong position amount");
            }

            amountGot = priceFeed.normExchangeFromExact(
                from,
                to,
                amount,
                optionalPath,
                amountBound
            );
        } else {
            if (from == baseToken) {
                require(amountBound <= info.balanceBase, "TPRP: wrong base amount");
            } else {
                require(amountBound <= info.balancePosition, "TPRP: wrong position amount");
            }

            amountGot = priceFeed.normExchangeToExact(from, to, amount, optionalPath, amountBound);

            (amount, amountGot) = (amountGot, amount);
        }

        emit ProposalExchanged(proposalId, msg.sender, from, to, amount, amountGot);

        if (from == baseToken) {
            info.balanceBase -= amount;
            info.balancePosition += amountGot;
        } else {
            info.balanceBase += amountGot;
            info.balancePosition -= amount;

            if (info.balancePosition == 0) {
                emit ProposalPositionClosed(proposalId, from);
            }
        }
    }

    function getProposalInfos(
        uint256 offset,
        uint256 limit
    ) external view override returns (ProposalInfoExtended[] memory proposals) {
        return
            TraderPoolRiskyProposalView.getProposalInfos(
                _proposalInfos,
                _investors,
                offset,
                limit
            );
    }

    function getActiveInvestmentsInfo(
        address user,
        uint256 offset,
        uint256 limit
    ) external view override returns (ActiveInvestmentInfo[] memory investments) {
        return
            TraderPoolRiskyProposalView.getActiveInvestmentsInfo(
                _activeInvestments[user],
                _baseBalances,
                _lpBalances,
                _proposalInfos,
                user,
                offset,
                limit
            );
    }

    function getCreationTokens(
        address token,
        uint256 baseInvestment,
        uint256 instantTradePercentage,
        address[] calldata optionalPath
    )
        external
        view
        override
        returns (uint256 positionTokens, uint256 positionTokenPrice, address[] memory path)
    {
        return
            _parentTraderPoolInfo.getCreationTokens(
                token,
                baseInvestment.percentage(instantTradePercentage),
                optionalPath
            );
    }

    function getInvestTokens(
        uint256 proposalId,
        uint256 baseInvestment
    )
        external
        view
        override
        returns (uint256 baseAmount, uint256 positionAmount, uint256 lp2Amount)
    {
        return
            _parentTraderPoolInfo.getInvestTokens(
                _proposalInfos[proposalId],
                proposalId,
                baseInvestment
            );
    }

    function getInvestmentPercentage(
        uint256 proposalId,
        address user,
        uint256 toBeInvested
    ) public view override returns (uint256) {
        uint256 lpBalance = totalLPBalances[user] +
            IERC20(_parentTraderPoolInfo.parentPoolAddress).balanceOf(user);

        return
            lpBalance > 0
                ? (_lpBalances[user][proposalId] + toBeInvested).ratio(PERCENTAGE_100, lpBalance)
                : PERCENTAGE_100;
    }

    function getUserInvestmentsLimits(
        address user,
        uint256[] calldata proposalIds
    ) external view override returns (uint256[] memory lps) {
        return _parentTraderPoolInfo.getUserInvestmentsLimits(_lpBalances, user, proposalIds);
    }

    function getDivestAmounts(
        uint256[] calldata proposalIds,
        uint256[] calldata lp2s
    ) external view override returns (Receptions memory receptions) {
        return _parentTraderPoolInfo.getDivestAmounts(_proposalInfos, proposalIds, lp2s);
    }

    function getExchangeAmount(
        uint256 proposalId,
        address from,
        uint256 amount,
        address[] calldata optionalPath,
        ExchangeType exType
    ) external view override returns (uint256, address[] memory) {
        return
            _parentTraderPoolInfo.getExchangeAmount(
                _proposalInfos[proposalId].token,
                proposalId,
                from,
                amount,
                optionalPath,
                exType
            );
    }

    function _investActivePortfolio(
        uint256 proposalId,
        uint256 baseInvestment,
        uint256 baseToExchange,
        uint256 lpInvestment,
        address[] memory optionalPath,
        uint256 minPositionOut
    ) internal {
        ProposalInfo storage info = _proposalInfos[proposalId];

        info.lpLocked += lpInvestment;
        info.balanceBase += baseInvestment - baseToExchange;

        if (baseToExchange > 0) {
            uint256 amountGot = priceFeed.normExchangeFromExact(
                _parentTraderPoolInfo.baseToken,
                info.token,
                baseToExchange,
                optionalPath,
                minPositionOut
            );

            info.balancePosition += amountGot;

            emit ProposalActivePortfolioExchanged(
                proposalId,
                _parentTraderPoolInfo.baseToken,
                info.token,
                baseToExchange,
                amountGot
            );
        }
    }

    function _divestActivePortfolio(
        uint256 proposalId,
        uint256 lp2,
        uint256 minPositionOut
    ) internal returns (uint256 receivedBase) {
        ProposalInfo storage info = _proposalInfos[proposalId];
        uint256 supply = totalSupply(proposalId);

        uint256 baseShare = receivedBase = info.balanceBase.ratio(lp2, supply);
        uint256 positionShare = info.balancePosition.ratio(lp2, supply);

        if (positionShare > 0) {
            uint256 amountGot = priceFeed.normExchangeFromExact(
                info.token,
                _parentTraderPoolInfo.baseToken,
                positionShare,
                new address[](0),
                minPositionOut
            );

            info.balancePosition -= positionShare;
            receivedBase += amountGot;

            emit ProposalActivePortfolioExchanged(
                proposalId,
                info.token,
                _parentTraderPoolInfo.baseToken,
                positionShare,
                amountGot
            );
        }

        info.balanceBase -= baseShare;
    }

    function _divestProposalTrader(uint256 proposalId, uint256 lp2) internal returns (uint256) {
        require(
            _proposalInfos[proposalId].balancePosition == 0,
            "TPRP: divesting with open position"
        );

        return _divestActivePortfolio(proposalId, lp2, 0);
    }

    function _baseInProposal(uint256 proposalId) internal view override returns (uint256) {
        return
            _proposalInfos[proposalId].balanceBase +
            priceFeed.getNormPriceOut(
                _proposalInfos[proposalId].token,
                _parentTraderPoolInfo.baseToken,
                _proposalInfos[proposalId].balancePosition
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../interfaces/user/IUserRegistry.sol";

contract UserRegistry is IUserRegistry, EIP712Upgradeable, OwnableUpgradeable {
    bytes32 public documentHash;

    mapping(address => UserInfo) public userInfos;

    event UpdatedProfile(address user, string url);
    event Agreed(address user, bytes32 documentHash);

    function __UserRegistry_init(string calldata name) public initializer {
        __EIP712_init(name, "1");
        __Ownable_init();
    }

    function changeProfile(string calldata url) public override {
        userInfos[msg.sender].profileURL = url;

        emit UpdatedProfile(msg.sender, url);
    }

    function agreeToPrivacyPolicy(bytes calldata signature) public override {
        require(documentHash != 0, "UserRegistry: privacy policy is not set");

        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encode(keccak256("Agreement(bytes32 documentHash)"), documentHash))
        );

        require(
            ECDSAUpgradeable.recover(digest, signature) == msg.sender,
            "UserRegistry: invalid signature"
        );

        userInfos[msg.sender].signatureHash = keccak256(abi.encodePacked(signature));

        emit Agreed(msg.sender, documentHash);
    }

    function changeProfileAndAgreeToPrivacyPolicy(
        string calldata url,
        bytes calldata signature
    ) external override {
        agreeToPrivacyPolicy(signature);
        changeProfile(url);
    }

    function agreed(address user) external view override returns (bool) {
        return userInfos[user].signatureHash != 0;
    }

    function setPrivacyPolicyDocumentHash(bytes32 hash) external override onlyOwner {
        documentHash = hash;
    }
}