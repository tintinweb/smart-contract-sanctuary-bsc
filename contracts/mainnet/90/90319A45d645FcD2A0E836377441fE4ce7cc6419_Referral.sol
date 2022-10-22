// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IReferral.sol";
import "./access/AccessControl.sol";


contract Referral is IReferral,AccessControl{

    mapping (address=>address) private _referrals; 
    
    mapping (address=>uint256) private _referralCounts;
    
    address private _rootAddress;
 
    constructor(address rootAddress_){
        _rootAddress = rootAddress_;
    }

    function getReferral(address _address)public view returns(address){
        return _referrals[_address];
    }

    function isBindReferral(address _address) public view returns(bool)
    {
        return getReferral(_address) != address(0) || _address == _rootAddress;
    }

    function getReferralCount(address _address) public view returns(uint256){
        return _referralCounts[_address];
    }

    function bindReferral(address _referral,address _user) external onlyOperator{
        require(isBindReferral(_referral),"Referral not bind");
        require(!isBindReferral(_user),"User is bind");
        _referrals[_user] = _referral;
        _referralCounts[_referral]++;
        emit BindReferral(_referral, _user);
    }

    function getReferrals(address _address,uint256 _num) external view returns(address[] memory){
        address[] memory result;
        result = new address[](_num);
        for(uint256 i=0;i<_num;i++){
            _address = getReferral(_address);
            if(_address == address(0))break;
            result[i] = _address;
        }
        return result;
    }

    function getRootAddress()external view returns(address){
        return _rootAddress;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IReferral{
    
    event BindReferral(address indexed referral,address indexed user);
    
    function getReferral(address _address)external view returns(address);

    function isBindReferral(address _address) external view returns(bool);

    function getReferralCount(address _address) external view returns(uint256);

    function bindReferral(address _referral,address _user) external;

    function getReferrals(address _address,uint256 _num) external view returns(address[] memory);

    function getRootAddress()external view returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract AccessControl is Ownable{
  
    mapping(address => bool) private _operators;

    event SetOperator(address indexed add, bool value);

    function setOperator(address _operator, bool _v) external onlyOwner {
        _operators[_operator] = _v;
        emit SetOperator(_operator, _v);
    }

    function isOperator(address _address) external view returns(bool){
        return  _operators[_address];
    }

    modifier onlyOperator() {
        require(_operators[msg.sender]);
        _;
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