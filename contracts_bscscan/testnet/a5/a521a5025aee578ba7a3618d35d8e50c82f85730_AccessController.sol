/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
    function renounceOwnership() external virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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
       isAdmin[user]= _isSuperAdmin;
       emit SuperAdminUpdated(user, _isSuperAdmin);
   }

}