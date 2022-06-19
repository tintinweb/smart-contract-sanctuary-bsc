/**
 *Submitted for verification at BscScan.com on 2022-06-18
*/

// SPDX-License-Identifier: MIT


// File: Datalayer/Models.sol




pragma solidity ^0.8.0;

struct Referral { 
   
   address Wallet;
   string Code;
   uint YouReceive;
   uint FriendsReceive;
   bool IsActive;
   uint256 CreateDate;

}

// File: Utils/Context.sol


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

// File: Access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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
    address public _owner;

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

// File: Main.sol






pragma solidity ^0.8.0;


contract Xegora is Ownable {
    
    string public _Name; // Holds the name of the token
    string public _Version;
    uint public _RefYouRecive;
    uint public _RefFriendReceive;
    
    uint public referralCount;

    mapping (address => Referral) public _Referral;
    event savingsReferralEvent(address indexed _myAddress, Referral);
    
   
   //-----------------------------------------
    mapping(address => bool) public authorized;
  
    modifier onlyAuthorized() {
        require(authorized[msg.sender] || _owner == msg.sender);
        _;
    }

    function addAuthorized(address _toAdd) onlyOwner public {
        require(_toAdd != address(0));
        authorized[_toAdd] = true;
    }

    function removeAuthorized(address _toRemove) onlyOwner public {
        require(_toRemove != address(0));
        require(_toRemove != msg.sender);
        authorized[_toRemove] = false;
    }
    //-----------------------------------------
  
    constructor(string memory Name,string memory Version,uint Refu,uint RefFr,uint RefCount) {
        _Name = Name; 
        _Version = Version;
        _RefYouRecive = Refu;
        _RefFriendReceive = RefFr;
        referralCount = RefCount;
    }

     //-----------------------------------------

    function updateRefDefault(uint you,uint friend) public onlyAuthorized{

        _RefYouRecive = you;
        _RefFriendReceive = friend;

    }

    function getRefDefault() public view onlyAuthorized returns(uint YouRecive,uint FriendReceive){
        YouRecive = _RefYouRecive;
        FriendReceive = _RefFriendReceive;
    }

     //-----------------------------------------
    
    function addReferral(string memory code,uint youReceive,uint friendReceive,bool isActive,uint256 createDate) public {

     require(_Referral[msg.sender].Wallet != address(0));
         
     _Referral[msg.sender] = Referral(msg.sender,code,youReceive,friendReceive,isActive,createDate);
     emit savingsReferralEvent(msg.sender,_Referral[msg.sender]);
    }

    function updateReferral(address wallet,uint youReceive,uint friendReceive,bool isActive,uint256 createDate) public onlyAuthorized{

        Referral memory _oldRef = _Referral[wallet];

        _Referral[wallet] = Referral(_oldRef.Wallet,_oldRef.Code,youReceive,friendReceive,isActive,createDate);
    }

    function getReferral() public view returns(Referral memory){

        return  _Referral[msg.sender];
    } 


    function GetOwnerList() public view onlyAuthorized returns(address){

     return _owner;

    }


}