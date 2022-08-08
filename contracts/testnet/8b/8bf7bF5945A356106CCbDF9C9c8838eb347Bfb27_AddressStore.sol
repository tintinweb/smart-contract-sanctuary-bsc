// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAddressStore.sol";

contract AddressStore is IAddressStore, Ownable {
    // Keys for standard contracts in the system
    string public constant TIMELOCKED_ADMIN = "TimelockedAdmin";
    string public constant STK_BNB = "stkBNB";
    string public constant FEE_VAULT = "FeeVault";
    string public constant STAKE_POOL = "StakePool";
    string public constant UNDELEGATION_HOLDER = "UndelegationHolder";

    // the address store
    mapping(string => address) private _store;

    // emitted when an address is set
    event SetAddress(string indexed key, address value);

    constructor() {} // solhint-disable-line no-empty-blocks

    function setAddr(string memory key, address value) public override onlyOwner {
        _store[key] = value;

        emit SetAddress(key, value);
    }

    function setTimelockedAdmin(address addr) external override {
        setAddr(TIMELOCKED_ADMIN, addr);
    }

    function setStkBNB(address addr) external override {
        setAddr(STK_BNB, addr);
    }

    function setFeeVault(address addr) external override {
        setAddr(FEE_VAULT, addr);
    }

    function setStakePool(address addr) external override {
        setAddr(STAKE_POOL, addr);
    }

    function setUndelegationHolder(address addr) external override {
        setAddr(UNDELEGATION_HOLDER, addr);
    }

    function getAddr(string memory key) public view override returns (address) {
        return _store[key];
    }

    function getTimelockedAdmin() external view override returns (address) {
        return getAddr(TIMELOCKED_ADMIN);
    }

    function getStkBNB() external view override returns (address) {
        return getAddr(STK_BNB);
    }

    function getFeeVault() external view override returns (address) {
        return getAddr(FEE_VAULT);
    }

    function getStakePool() external view override returns (address) {
        return getAddr(STAKE_POOL);
    }

    function getUndelegationHolder() external view override returns (address) {
        return getAddr(UNDELEGATION_HOLDER);
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

pragma solidity ^0.8.7;

interface IAddressStore {
    function setAddr(string memory key, address value) external;

    function setTimelockedAdmin(address addr) external;

    function setStkBNB(address addr) external;

    function setFeeVault(address addr) external;

    function setStakePool(address addr) external;

    function setUndelegationHolder(address addr) external;

    function getAddr(string calldata key) external view returns (address);

    function getTimelockedAdmin() external view returns (address);

    function getStkBNB() external view returns (address);

    function getFeeVault() external view returns (address);

    function getStakePool() external view returns (address);

    function getUndelegationHolder() external view returns (address);
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