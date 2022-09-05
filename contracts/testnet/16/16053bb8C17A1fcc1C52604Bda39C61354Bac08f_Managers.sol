// DATA LAKE TASK - MANAGERS
// Manager in Data Lake Contract is someone, who manages certain consents - this manager
// is usually a trust entity that can add people to certain owned consents
// please review the following code and make changes to make the code fully working
// 1. We have a function to updateManager - this function works with _managersToConsents and
//       _managers in order to log active managers and to which consents is a certain manager; 
//       these variables need to change accordingly to changes pushed to updateManager function
// 2. We have some basic queries to see active managers, to check if a certain address is a 
//       manages and which consents does a certain manager manage (by address again)
// 3. We have a function _isManagerAllowedToChangeConsents -- what is its exact goal? is the 
//       function written properly? describe, fix, explain the code

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// contents of imports are not needed for this task
import "./IManagers.sol";
import "./Ownable.sol";

contract Managers is IManagers, Ownable {
    //Event
    event ManagerWithConsentsChanged(address manager,uint32[] consentsIds,address msgSender);

    //variable _managersToConsents serves the purpose of keeping track which consents are managed by a certain manager
    mapping(address => uint32[]) private _managersToConsents;
    
    // variable _managers serves as a list of active managers
    address[] private _managers;
    //The manager who creates contract is super manager with all consents
    constructor(uint32[] memory consentsIds){
        _managers.push(msg.sender);
        _managersToConsents[msg.sender] = consentsIds;
    }
    //TASK 1 - create updateManager function
    // update manager function serves to edit managers rights
    function updateManager(address manager, uint32[] memory consentsIds) external onlyOwner override {
        // 1. logical assumption
        // we are updating manager with consents i.e. [1,2], what is the condition and what 
        //will happen to _managers
        /*
        if ( !_isManagerAllowedToChangeConsents(consentsIds) ) {
            revert("Manager does not have consents to change");
        }*/        
        require(_isManagerAllowedToChangeConsents(consentsIds),"Manager does not have consents to change");
        
        // 2. logical assumption
        // what if we are updating manager with empty array of consents he's manager to, what is the condition
        // and what will happen to _managers, when he won't have anymore any consents under management
        //Spesific consents id or ids can be used for this operation or only super admin
        if ( consentsIds.length == 0) {
            delete _managersToConsents[manager];
            //delete _managers[X]
            _removeManager(manager);
            emit ManagerWithConsentsChanged(manager, consentsIds, _msgSender());
            return;
        }
        // 3. logical assumption
        // is _managersToConsents going to change? how?
        (bool exists,) = _doesManagerExists(manager);
        if(!exists){
            _managers.push(manager);
        }
        _managersToConsents[manager] = consentsIds;
        //
        emit ManagerWithConsentsChanged(manager, consentsIds, _msgSender());
    }
    //Returns index of manager
    function _doesManagerExists(address manager)internal view returns(bool,uint){
        for(uint i=0;i<_managers.length;i++){
            if(_managers[i]==manager){
                return (true,i);
            }
        }
        return (false,0);
    }
    //Removes manager that stored in index
    function _removeManager(address manager)internal{
        (bool exists,uint index) = _doesManagerExists(manager);
        require(index < _managers.length);
        require(exists);
        //Move last manager in array to manager that will be removed
        _managers[index] = _managers[_managers.length-1];
        //pop managers array
        _managers.pop();
    }
    //TASK 2 - fill in the following 3 functions        
    // we want to get a list of all active managers
    function getManagers() external view override returns (address[] memory) {
        return _managers;
    }
    // is he still a manager, does he have some consents he manages?
    function isManager(address manager) external view override returns (bool) {
        if(_managersToConsents[manager].length>0){
            return true;
        }
        return false;
    }
    // which consents he manages?
    function getManagerConsents(address manager) external view override returns (uint32[] memory) {
        return _managersToConsents[manager];
    }

    //TASK 3 - is the following function written correctly? (if not, can you fix it?) 
    //what does the following function do? (describe step-by-step)
    function _isManagerAllowedToChangeConsents(uint32[] memory consentsIds) internal view returns (bool) {
        //Retreive msg.sender consents
        uint32 [] memory managerConsents = _managersToConsents[_msgSender()];
        //bool result = false;
        //Consents match counter
        uint32 matches = 0;        
        if (managerConsents.length > 0 && managerConsents.length >= consentsIds.length) {
            //Does the manager(msg.sender) have the same consent that the manager(msg.sender) sets for another manager?
            for (uint32 i = 0; i < consentsIds.length; i++) {
                bool found = false;
                for (uint32 mi = 0; mi < managerConsents.length; mi++) {
                    //if matches
                    if (consentsIds[i] == managerConsents[mi]) {
                        found = true;
                        matches++;
                    }
                }
                //If a consents not matched with msg.sender consents return false
                if (found == false) {
                    return false;
                }
            }
            //If every consents id in consentsIds did not match with manager(msg.sender) consents in loop 
            if(matches<consentsIds.length){
                return false;
            }
            //The Manager(msg.sender) can change consents
            return true;
            //result = true;
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IManagers{
    function updateManager(address manager, uint32[] memory consentsIds) external;
    function getManagers() external view  returns (address[] memory);
    function isManager(address manager) external view  returns (bool);
    function getManagerConsents(address manager) external view  returns (uint32[] memory);
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