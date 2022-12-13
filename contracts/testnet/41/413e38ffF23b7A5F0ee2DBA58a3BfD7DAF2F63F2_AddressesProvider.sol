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

// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../AddressProvider/IAddressesProvider.sol";

// formatBytes32String("string here");
contract AddressesProvider is Ownable, IAddressesProvider {
  // Map of registered addresses (identifier => registeredAddress)
  mapping(bytes32 => address) private _addresses;

  // Main identifiers
  bytes32 private constant ACL_ADMIN = "ACL_ADMIN";
  bytes32 private constant ACL_MANAGER = "ACL_MANAGER";
  bytes32 private constant ZAP_CONTRACT = "ZAP_CONTRACT";
  bytes32 private constant CROP_YARD_CONTRACT = "CROP_YARD_CONTRACT";
  bytes32 private constant BARTER_ROUTER = "BARTER_ROUTER";
  bytes32 private constant BARTER_FACTORY = "BARTER_FACTORY";
  bytes32 private constant UPRIGHT_CONTRACT = "UPRIGHT_CONTRACT";
  bytes32 private constant PRIME_CONTRACT = "PRIME_CONTRACT";
  bytes32 private constant FISK_CONTRACT = "FISK_CONTRACT";
  bytes32 private constant WHITELIST_CONTRACT = "WHITELIST_CONTRACT";
  bytes32 private constant BORROW_LEND_CONTRACT = "BORROW_LEND_CONTRACT";
  bytes32 private constant BSC_VIADUCT = "BSC_VIADUCT";
  /******************************COINS****************************** */
  bytes32 private constant SPENT = "SPENT";
  bytes32 private constant eUSD = "eUSD";
  bytes32 private constant BST = "BST";
  /******************************STAKE****************************** */

  bytes32 private constant UPRIGHT_STABLE_CONTRACT = "UPRIGHT_STABLE_CONTRACT";
  bytes32 private constant UPRIGHT_LP_CONTRACT = "UPRIGHT_LP_CONTRACT";
  bytes32 private constant UPRIGHT_SWAP_TOKEN_CONTRACT = "UPRIGHT_SWAP_TOKEN_CONTRACT";
  bytes32 private constant UPRIGHT_BST_CONTRACT = "UPRIGHT_BST_CONTRACT";

  event AddressSet(bytes32 id, address oldAddress, address newAddress);
  event ACLManagerUpdated(address oldAclManager, address newAclManager);
  event ACLAdminUpdated(address oldAclAdmin, address newAclAdmin);

  constructor(address owner) {
    transferOwnership(owner);
  }

  /***************************************************** */
  /*********************GETTERS************************* */
  /***************************************************** */
  function getAddress(bytes32 id) public view override returns (address) {
    return _addresses[id];
  }

  function getSpent() public view override returns (address) {
    return getAddress(SPENT);
  }

  function getEusd() public view override returns (address) {
    return getAddress(eUSD);
  }

  function getZapContract() public view override returns (address) {
    return getAddress(ZAP_CONTRACT);
  }

  function getBscViaDuctContract() public view override returns (address) {
    return getAddress(BSC_VIADUCT);
  }

  function getBarterRouter() public view override returns (address) {
    return getAddress(BARTER_ROUTER);
  }

  function getBarterFactory() public view override returns (address) {
    return getAddress(BARTER_FACTORY);
  }

  function getUpRightContract() public view override returns (address) {
    return getAddress(UPRIGHT_CONTRACT);
  }

  function getCropYardContract() public view override returns (address) {
    return getAddress(CROP_YARD_CONTRACT);
  }

  function getPrimeContract() public view override returns (address) {
    return getAddress(PRIME_CONTRACT);
  }

  function getFiskContract() public view override returns (address) {
    return getAddress(FISK_CONTRACT);
  }

  function getWhitelistContract() public view override returns (address) {
    return getAddress(WHITELIST_CONTRACT);
  }

  function getACLManager() public view override returns (address) {
    return getAddress(ACL_MANAGER);
  }

  function getACLAdmin() public view override returns (address) {
    return getAddress(ACL_ADMIN);
  }

  function getUprightStableContract() public view override returns (address) {
    return getAddress(UPRIGHT_STABLE_CONTRACT);
  }

  function getUprightLpContract() public view override returns (address) {
    return getAddress(UPRIGHT_LP_CONTRACT);
  }

  function getUprightSwapTokenContract() public view override returns (address) {
    return getAddress(UPRIGHT_SWAP_TOKEN_CONTRACT);
  }

  function getUprightBstContract() public view override returns (address) {
    return getAddress(UPRIGHT_BST_CONTRACT);
  }

  function getBorrowLendContract() public view override returns (address) {
    return getAddress(BORROW_LEND_CONTRACT);
  }

  /***************************************************** */
  /*********************SETTERS************************* */
  /***************************************************** */

  function setAddress(bytes32 id, address newAddress) public override onlyOwner {
    address oldAddress = _addresses[id];
    _addresses[id] = newAddress;
    emit AddressSet(id, oldAddress, newAddress);
  }

  function setACLAdmin(address newAclAdmin) public override onlyOwner {
    address oldAclAdmin = _addresses[ACL_ADMIN];
    _addresses[ACL_ADMIN] = newAclAdmin;
    emit ACLAdminUpdated(oldAclAdmin, newAclAdmin);
  }

  function setACLManager(address newAclManager) public override onlyOwner {
    address oldAclManager = _addresses[ACL_MANAGER];
    _addresses[ACL_MANAGER] = newAclManager;
    emit ACLManagerUpdated(oldAclManager, newAclManager);
  }
}

// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

interface IAddressesProvider {
  /***************************************************** */
  /*********************GETTERS************************* */
  /***************************************************** */
  function getAddress(bytes32 id) external view returns (address);

  function getACLManager() external view returns (address);

  function getSpent() external view returns (address);

  function getEusd() external view returns (address);

  function getACLAdmin() external view returns (address);

  function getZapContract() external view returns (address);

  function getBscViaDuctContract() external returns (address);

  function getBarterRouter() external view returns (address);

  function getBarterFactory() external view returns (address);

  function getUpRightContract() external view returns (address);

  function getCropYardContract() external view returns (address);

  function getPrimeContract() external view returns (address);

  function getFiskContract() external view returns (address);

  function getWhitelistContract() external view returns (address);

  function getUprightStableContract() external view returns (address);

  function getUprightLpContract() external view returns (address);

  function getUprightSwapTokenContract() external view returns (address);

  function getUprightBstContract() external view returns (address);

  function getBorrowLendContract() external view returns (address);

  /***************************************************** */
  /*********************SETTERS************************* */
  /***************************************************** */

  function setAddress(bytes32 id, address newAddress) external;

  function setACLManager(address newAclManager) external;

  function setACLAdmin(address newAclAdmin) external;
}