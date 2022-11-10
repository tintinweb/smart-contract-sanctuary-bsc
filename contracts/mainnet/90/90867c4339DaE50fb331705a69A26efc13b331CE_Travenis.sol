/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

//SPDX-License-Identifier: MIT
// File: @saleStatuszeppelin/contracts/utils/Context.sol


// saleStatusZeppelin Contracts v4.4.1 (utils/Context.sol)


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

// File: @saleStatuszeppelin/contracts/access/Ownable.sol


// saleStatusZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.17;


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


pragma solidity ^0.8.17;
//File: Travenis.sol

contract Travenis is Ownable {

 bool public saleStatus = true;
 address payable public Recipient = payable(address(0xeA4a8f98c12D433197253E8413e9b3DF10d26395)); //replace 0x123 with your Recipient address in which you want to receive BNB

 mapping(address => uint256) public userContribution;
 uint256 public minBNBcap; 
 uint256 public maxBNBcap;
 uint256 public hardcap;
 uint256 public softcap;
 uint256 public totalBnbRaised = 0;
                    
 
 constructor () {
     minBNBcap = 0.01 ether; // 0.01 BNB
     maxBNBcap = 10 ether; // 10 BNB
     softcap = 100 ether; // 100 BNB
     hardcap = 200 ether; // 200 BNB
 }
 


 function changeRecipient (address payable _newRecipient) external onlyOwner {
    Recipient = _newRecipient;
 }
 
 function toggleSaleStatus () external onlyOwner {
    saleStatus = !saleStatus;
 }

 function setMinAndmaxBNBcap (uint256 min, uint256 max) external onlyOwner  {
    minBNBcap = min;
    maxBNBcap = max;
 }

 function setHardcap (uint256 newHardCap) external onlyOwner {
    hardcap = newHardCap;
 }

 function setSoftcap (uint256 newSoftCap) external onlyOwner {
    softcap = newSoftCap;
 }

 
 function Deposit () public payable {
     require(totalBnbRaised <= hardcap, "Hardcap Reached");
     require(saleStatus == true, "Sale is not active yet");
     require(userContribution[msg.sender]+msg.value >= minBNBcap && userContribution[msg.sender]+msg.value <= maxBNBcap, "Not in between minimum Cap and maximum Cap per Recipient"); 
     forwardFunds(msg.value);
 }

 
 function forwardFunds(uint256 _userContribution) internal returns (bool success){
    userContribution[msg.sender] += _userContribution;
    (bool sent,) = Recipient.call{value: _userContribution}("");
    require (sent, "bnb transfer failed");
    totalBnbRaised += _userContribution;
    return true;
 }
 
 receive() payable external {
     Deposit();
 }
 
}