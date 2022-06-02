/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


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

// File: contracts/sbcc.sol


pragma solidity ^0.8.0;


contract SBCCAuth is Ownable{

    struct MemberInfo{
        uint index;
        int value;
    }

    mapping(address => MemberInfo) internal map;
    address[] internal keyList;
    
    function add(address _key, int _value) public onlyOwner{
        MemberInfo storage memberInfo = map[_key];
        memberInfo.value = _value;
        if(memberInfo.index > 0){ // memberInfo exists
            // do nothing
            return;
        }else { // new memberInfo
            keyList.push(_key);
            uint keyListIndex = keyList.length - 1;
            memberInfo.index = keyListIndex + 1;
        }
    }

    function remove(address _key) public onlyOwner{
        MemberInfo storage memberInfo = map[_key];
        require(memberInfo.index != 0); // memberInfo not exist
        require(memberInfo.index <= keyList.length); // invalid index value
        
        // Move an last element of array into the vacated key slot.
        uint keyListIndex = memberInfo.index - 1;
        uint keyListLastIndex = keyList.length - 1;
        map[keyList[keyListLastIndex]].index = keyListIndex + 1;
        keyList[keyListIndex] = keyList[keyListLastIndex];
        keyList.pop();
        delete map[_key];
    }
    
    function size() public view returns (uint) {
        return uint(keyList.length);
    }
    
    function contains(address _key) public view returns (bool) {
        return map[_key].index > 0;
    }
    
    function getByKey(address _key) public view returns (int) {
        return map[_key].value;
    }
    
    function getByIndex(uint _index) public view returns (int) {
        require(_index >= 0);
        require(_index < keyList.length);
        return map[keyList[_index]].value;
    }

}