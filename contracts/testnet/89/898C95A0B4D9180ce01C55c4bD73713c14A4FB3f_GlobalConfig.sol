// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../lib/LibList.sol";

contract GlobalConfig is Ownable {

    using LibList for mapping(address => bool);

    // Authrozied brokers, who is allowed to call match in exchange.
    mapping(address => bool) public brokers;
    // Authrozied user, who is allowed to call pause/unpause in perpetual.
    mapping(address => bool) public pauseControllers;
    // Authrozied user, who is allowed to call disable/enable withdraw in perpetual.
    mapping(address => bool) public withdrawControllers;
    // components can call some dangerous methods in perpetual.
    mapping(address => mapping(address => bool)) public components;

    event CreateGlobalConfig();
    event AddBroker(address indexed broker);
    event RemoveBroker(address indexed broker);
    event AddPauseController(address indexed controller);
    event RemovePauseController(address indexed controller);
    event AddWithdrawController(address indexed controller);
    event RemovedWithdrawController(address indexed controller);
    event AddComponent(address indexed perpetual, address indexed component);
    event RemovedComponent(address indexed perpetual, address indexed component);

    constructor() {
        emit CreateGlobalConfig();
    }

    /**
     * @dev Add authorized broker.
     *
     * @param broker Address of broker.
     */
    function addBroker(address broker) external onlyOwner {
        brokers.add(broker);
        emit AddBroker(broker);
    }

    /**
     * @dev Remove authorized broker.
     *
     * @param broker Address of broker.
     */
    function removeBroker(address broker) external onlyOwner {
        brokers.remove(broker);
        emit RemoveBroker(broker);
    }

    /**
     * @dev Test if a address is a component of sender (perpetual).
     *
     * @param component Address of component contract.
     * @return True if given address is a component of sender.
     */
    function isComponent(address component) external view returns (bool) {
        return components[msg.sender][component];
    }

     /**
     * @dev Add a component to whitelist of a perpetual.
     *
     * @param perpetual Address of perpetual.
     * @param component Address of component.
     */
    function addComponent(address perpetual, address component) external onlyOwner {
        require(!components[perpetual][component], "component already exist");
        components[perpetual][component] = true;
        emit AddComponent(perpetual, component);
    }

     /**
     * @dev Remove a component from whitelist of a perpetual.
     *
     * @param perpetual Address of perpetual.
     * @param component Address of component.
     */
    function removeComponent(address perpetual, address component) external onlyOwner {
        require(components[perpetual][component], "component not exist");
        components[perpetual][component] = false;
        emit RemovedComponent(perpetual, component);
    }

    /**
     * @dev Add authorized pause controller.
     *
     * @param controller Address of controller.
     */
    function addPauseController(address controller) external onlyOwner {
        pauseControllers.add(controller);
        emit AddPauseController(controller);
    }

    /**
     * @dev Remove authorized pause controller.
     *
     * @param controller Address of controller.
     */
    function removePauseController(address controller) external onlyOwner {
        pauseControllers.remove(controller);
        emit RemovePauseController(controller);
    }

    /**
     * @dev Add authorized withdraw controller.
     *
     * @param controller Address of controller.
     */
    function addWithdrawController(address controller) external onlyOwner {
        withdrawControllers.add(controller);
        emit AddWithdrawController(controller);
    }

    /**
     * @dev Remove authorized withdraw controller.
     *
     * @param controller Address of controller.
     */
    function removeWithdrawController(address controller) external onlyOwner {
        withdrawControllers.remove(controller);
        emit RemovedWithdrawController(controller);
    }
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;

library LibList {
    /// @dev add Address into list
    /// @param list Storage of list
    /// @param target Address to add
    function add(mapping(address => bool) storage list, address target) internal {
        require(!list[target], "address already exist");
        list[target] = true;
    }

    /// @dev remove Address from list
    /// @param list Storage of mapping(address => bool)
    /// @param target Address to add
    function remove(mapping(address => bool) storage list, address target) internal {
        require(list[target], "address not exist");
        delete list[target];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}