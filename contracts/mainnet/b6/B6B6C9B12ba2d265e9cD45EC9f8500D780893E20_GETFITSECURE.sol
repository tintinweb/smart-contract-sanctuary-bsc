/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

// Sources flattened with hardhat v2.8.4 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

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


// File @openzeppelin/contracts/access/[email protected]


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


// File contracts/Misc/GETFITSECURE.sol



pragma solidity ^0.8.4;

contract GETFITSECURE is Ownable {
    mapping ( address => bytes32) private users;
    bytes32 private tknHash;
    constructor() Ownable() {}
    function setUserSecure (string memory _str) public returns (bool){
        users[msg.sender] = keccak256(abi.encodePacked(_str));
        return true;
    }
    function appSetUserSecure (string memory _tkn, string memory _str, address _addr) public returns (bool){
        require (keccak256(abi.encodePacked(_tkn)) == tknHash, "App not allowed");
        require (users[_addr] == bytes32(0), "Already registred");
        users[_addr] = keccak256(abi.encodePacked(_str));
        return true;
    }
    function isUserSecure (string memory _str, address user) public view returns (bool){
        return users[user] == keccak256(abi.encodePacked(_str));
    }
    function passSecure (address user) public view returns (bool){
        return users[user] != bytes32(0);
    }
    function resetUser (address _addr) public onlyOwner returns (bool){
        delete users[_addr];
        return true;
    }
    function setTknHash (string memory _str) public onlyOwner returns (bool){
        tknHash = keccak256(abi.encodePacked(_str));
        return true;
    }
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
    function withdraw() public payable onlyOwner {
        address payable to = payable(msg.sender);
        to.transfer(getBalance());
    }    
}