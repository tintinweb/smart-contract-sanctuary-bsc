// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../Constants.sol";
import "./interfaces/IStrategy.sol";
import "../interfaces/IWhiteList.sol";
import "../interfaces/IContractsRegistry.sol";

contract Strategy is IStrategy, Ownable {
  /// @notice Stores the address of ContractsRegistry contract.
  /// It is used to get addresses of main contracts as WhiteList
  /// @return address of ContractsRegistry contract.
  IContractsRegistry public registry;

  /// @param registry_ address of ContractRegistry contract.
  constructor(address registry_) {
    if (registry_ == address(0)) {
      revert ZeroAddress();
    }
    registry = IContractsRegistry(registry_);
  }

  /// @notice Set new address of ContractRegistry contract.
  /// @param registry_ new address of ContractRegistry contract.
  function setRegistry(address registry_) external onlyOwner {
    if (registry_ == address(0)) {
      revert ZeroAddress();
    }
    registry = IContractsRegistry(registry_);
    emit UpdatedRegistry(registry_);
  }

  /// @notice Validate transaction by checking addresses "from" and "to".
  /// @param from address of sender transaction;
  /// @param to address of recipient of sMILE tokens.
  function validateTransaction(
    address from,
    address to,
    uint256 /* amount */
  ) external view {
    IWhiteList whiteList = IWhiteList(
      registry.getContractByKey(WHITE_LIST_CONTRACT_CODE)
    );
    if (!(whiteList.isValidAddress(from) || whiteList.isValidAddress(to))) {
      revert InvalidAddresses();
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

uint256 constant WHITE_LIST_CONTRACT_CODE = 1000;
uint256 constant ENTITY_FACTORY_CONTRACT_CODE = 2000;
uint256 constant SWAP_MILE_CONTRACT_CODE = 3000;
uint256 constant MILESTONEBASED_CONTRACT_CODE = 4000;
uint256 constant VOTING_STRATEGY_CONTRACT_CODE = 5000;
uint256 constant ENTITY_STRATEGY_CONTRACT_CODE = 6000;
uint256 constant SMILE_CONTRACT_CODE = 7000;
uint256 constant SMILE_STRATEGY_CONTRACT_CODE = 8000;
uint256 constant MILE_CONTRACT_CODE = 9000;
uint256 constant PANCAKE_ROUTER_CONTRACT_CODE = 10000;

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface IWhiteList {
  /// @notice Emits when MilestoneBased contract or owner adds new address to the contract.
  /// @param newAddress address of new contract to add.
  event AddedNewAddress(address indexed newAddress);
  /// @notice Emits when owner remove address from the contract.
  /// @param invalidAddress address of contract for removing.
  event RemovedAddress(address indexed invalidAddress);

  /// @notice Add new address to the contract.
  /// @param newAddress address to add.
  function addNewAddress(address newAddress) external;

  /// @notice Add new addresses to the contract.
  /// @param newAddresses array of new addresses.
  function addNewAddressesBatch(address[] memory newAddresses) external;

  /// @notice Remove passed address from the contract.
  /// @param invalidAddress address for removing.
  function removeAddress(address invalidAddress) external;

  /// @notice Remove passed addresses from the contract.
  /// @param invalidAddresses array of addresses to remove.
  function removeAddressesBatch(address[] memory invalidAddresses) external;

  /// @notice Return limit of addresses with pagination of MB platform.
  /// @param offset index from which the function starts collecting addresses.
  /// @param limit amount of addresses to return.
  /// @return White list addresses array.
  function getWhitelistedAddresses(uint256 offset, uint256 limit)
    external
    view
    returns (address[] memory);

  /// @notice Return true if contract has such address, and false if doesn’t.
  /// @param accountAddress address to check.
  /// @return The presence of the address in the list.
  function isValidAddress(address accountAddress) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

// =====================================================================
//
// |  \/  (_) |         | |                 |  _ \                   | |
// | \  / |_| | ___  ___| |_ ___  _ __   ___| |_) | __ _ ___  ___  __| |
// | |\/| | | |/ _ \/ __| __/ _ \| '_ \ / _ \  _ < / _` / __|/ _ \/ _` |
// | |  | | | |  __/\__ \ || (_) | | | |  __/ |_) | (_| \__ \  __/ (_| |
// |_|  |_|_|_|\___||___/\__\___/|_| |_|\___|____/ \__,_|___/\___|\__,_|
//
// =====================================================================
// ======================= IContractsRegistry ==========================
// =====================================================================

/**
 * @dev External interface of `ContractsRegistry`
 */
interface IContractsRegistry {
  /**
   * @dev The error means that a certain field equal ZERO_ADDRESS, which shouldn't be
   *
   * Emitted when key registration
   */
  error ZeroAddress();

  /**
   * @dev The error means that an unregistered key was transmitted.
   *
   * Emitted when a method is called with an input parameter the key than the key must
   * be registered but it is not so
   */
  error KeyNotRegistered(uint256 key);

  /**
   * @dev The error means that the arrays have different lengths in the places where it is required
   */
  error ArrayDifferentLength();

  /**
   * @dev Emitted when `contractAddress` are set by `key` to register
   *
   * Note that `contractAddress` is the new address.
   * Note If `contractAddress` is `ZERO_ADDRESS` it's mean then it's delet
   */
  event UpdateKey(uint256 indexed key, address contractAddress);

  /**
   * @dev Emitted when `contractAddresses` are set by `keys` to register
   *
   * Note that `contractsAddresses` is the new addresses.
   */
  event UpdateKeys(uint256[] indexed keys, address[] contractsAddresses);

  /**
   * @dev Function to initialize the contract which replaces the constructor.
   * Appointment to establish the owner of the contract. Can be called only once
   */
  function initialize() external;

  /**
   * @dev Registers `contractAddress_` by `key_`.
   *
   * If `key_` had been registered, then the function will update
   * the address by key to a new one
   *
   * Requirements:
   *
   * - the caller must be `Owner`.
   * - `contractAddress_` must be not `ZERO_ADDRESS`
   *
   * Emits a {UpdateKey} event.
   */
  function registerContract(uint256 key_, address contractAddress_) external;

  /**
   * @dev Registers `contractsAddresses_` by `keys_`.
   *
   * If any key from `keys_` had been registered, then the function will update
   * the address by key to a new one
   *
   * Keys are tied to addresses, and addresses are tied to keys by the number
   * of the element in the arrays
   *
   * Requirements:
   *
   * - the caller must be `Owner`.
   * - `contractsAddresses_` must be not containts `ZERO_ADDRESS`
   * - arrays must be of the same length
   *
   * Emits a {UpdateKeys} event.
   */
  function registerContracts(
    uint256[] calldata keys_,
    address[] calldata contractsAddresses_
  ) external;

  /**
   * @dev Unregisters `contractAddress_` by `key_`.
   *
   * If `key_` had not been registered, then the function will revert
   *
   * Requirements:
   *
   * - the caller must be `Owner`.
   * - `key_` must be registered
   *
   * Emits a {UpdateKey} event.
   */
  function unregisterContract(uint256 key_) external;

  /**
   * @dev Returns the status of whether the `key_` is registered
   *
   * Returns types:
   * - `false` - if contract not registered
   * - `true` - if contract registered
   */
  function isRegistered(uint256 key_) external view returns (bool result);

  /**
   * @dev Returns the contract address by `key_`
   *
   * IMPORTANT: If `key_` had not been registered, then return `ZERO_ADDRESS`
   */
  function register(uint256 key_) external view returns (address result);

  /**
   * @dev Returns the contract address by `key_`
   *
   * IMPORTANT: If `key_` had not been registered, then the function will revert
   */
  function getContractByKey(uint256 key_)
    external
    view
    returns (address result);

  /**
   * @dev Returns the contracts addresses by `keys_`
   *
   * Keys are tied to addresses, and addresses are tied to keys by the number
   * of the element in the arrays
   *
   * IMPORTANT: If any key from `keys_` had not been registered, then the function will revert
   */
  function getContractsByKeys(uint256[] calldata keys_)
    external
    view
    returns (address[] memory result);
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.9;

interface IStrategy {
  /// @dev Throws if admin tries to set address of ContractRegistry to ZERO_ADDRESS
  error ZeroAddress();

  /// @dev Throws when both addresses(from, to) which passed to method validateTransaction
  /// are not registred in WhiteList contract
  error InvalidAddresses();

  /// @notice Emits when the administrator updates address of Registry contract.
  /// @param newRegistry address of new Registry contract.
  event UpdatedRegistry(address indexed newRegistry);

  /// @notice Set new address of ContractRegistry contract.
  /// @param registry_ new address of ContractRegistry contract.
  function setRegistry(address registry_) external;

  /// @notice Validate transaction by checking addresses "from" and "to".
  /// @param from address of sender transaction;
  /// @param to address of recipient of sMILE tokens.
  function validateTransaction(
    address from,
    address to,
    uint256 /* amount */
  ) external view;
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