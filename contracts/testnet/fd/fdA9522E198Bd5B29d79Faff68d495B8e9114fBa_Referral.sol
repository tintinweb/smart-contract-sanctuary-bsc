// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Referral is Ownable{

    mapping (address=>address) private _referrals; 
    
    mapping (address=>uint256) private _referralCount;

    mapping (address=>bool) private _whitelist;

    address public rootAddress;

    uint256 public activeCondition = 10;

    address public token;

    event BindParent(address indexed parent,address indexed user);
    event SetWhitelist(address indexed account,bool indexed v);
    event BatchSetWhitelist(address[] accounts,bool indexed v);
    event SetActiveCondition(uint256 activeCondition);

    constructor(address rootAddress_){
        rootAddress = rootAddress_;
        _setWhitelist(rootAddress,true);
    }

    function getParent(address _address)public view returns(address){
        return _referrals[_address];
    }

    function isBindParent(address _address) public view returns(bool)
    {
        return getParent(_address) != address(0) || _address == rootAddress;
    }

    function getReferralCount(address _address) public view returns(uint256){
        return _referralCount[_address];
    }

    function bindParent(address _parent,address _user) external{
        require(token == msg.sender,"not Token");
        require(isBindParent(_parent),"Parent not bind");
        require(!isBindParent(_user),"User is bind");
        _referrals[_user] = _parent;
        _referralCount[_parent]++;
        emit BindParent(_parent, _user);
    }

    function getParents(address _address,uint256 _num) external view returns(address[] memory){
        address[] memory result;
        result = new address[](_num);
        for(uint256 i=0;i<_num;i++){
            _address = getParent(_address);
            if(_address == address(0))break;
            result[i] = _address;
        }
        return result;
    }

    function isActive(address _address) external view returns(bool){
        return isWhitelist(_address) || getReferralCount(_address)>=activeCondition;
    }

    function isWhitelist(address _address) public view returns(bool){
        return _whitelist[_address];
    }

    function batchSetWhitelist(address[] calldata _addresses,bool _v) external onlyOwner {
        for(uint256 i=0;i<_addresses.length;i++){
            _whitelist[_addresses[i]] = _v;
        }
        emit BatchSetWhitelist(_addresses, _v);
    }

    function setWhitelist(address _address,bool _v) external onlyOwner{
        _setWhitelist(_address,_v);
    }

    function setToken(address _token)external {
        require(token == address(0),"Token is set");
        token = _token;
    }

    function setActiveCondition(uint256 _activeCondition)external onlyOwner{
        activeCondition = _activeCondition;
        emit SetActiveCondition(_activeCondition);
    }

    function _setWhitelist(address _address,bool _v) private {
         _whitelist[_address] = _v;
         emit SetWhitelist(_address, _v);
    }

    function getRootAddress()external view returns(address){
        return rootAddress;
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