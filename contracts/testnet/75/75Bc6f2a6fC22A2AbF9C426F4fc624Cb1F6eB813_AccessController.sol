// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface Access{
    function updateAdmin(address user, bool _isAdmin) external;
    function updateSuperAdmin(address user, bool _isSuperAdmin) external;
}

contract AccessController is Ownable{
    mapping(address => bool) public isAdmin;
    mapping(address => bool) public isSuperAdmin;
    address public marketplace;
    address public dex;
    address public factory;

    event AdminUpdated(address user, bool isAdmin);
    event SuperAdminUpdated(address user, bool isSuperAdmin); 

    constructor(){
        isAdmin[msg.sender]= true;
        isSuperAdmin[msg.sender]= true;
    }

    function setMarketplace(address _marketplace) external onlyOwner{
      marketplace = _marketplace;
    }

    function setDex(address _dex) external onlyOwner{
      dex = _dex;
    }

    function setFactory(address _factory) external onlyOwner{
      factory = _factory;
    }

    function updateAdmin(address user, bool _isAdmin) external{
       require(isSuperAdmin[msg.sender] == true, "Access Denied");
       Access(marketplace).updateAdmin(user,_isAdmin);
       Access(dex).updateAdmin(user,_isAdmin);
       Access(factory).updateAdmin(user,_isAdmin);
       isAdmin[user]= _isAdmin;
       emit AdminUpdated(user, _isAdmin);
   }

   function updateSuperAdmin(address user, bool _isSuperAdmin) external{
   require(isSuperAdmin[msg.sender] == true, "Access Denied");
       isSuperAdmin[user]= _isSuperAdmin;
       Access(marketplace).updateSuperAdmin(user,_isSuperAdmin);
       Access(dex).updateSuperAdmin(user,_isSuperAdmin);
       Access(factory).updateSuperAdmin(user,_isSuperAdmin);
       isSuperAdmin[user]= _isSuperAdmin;
       emit SuperAdminUpdated(user, _isSuperAdmin);
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