/**
 *Submitted for verification at BscScan.com on 2022-04-22
*/

// File: @openzeppelin/contracts/utils/Context.sol

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

// File: contracts/Util.sol

pragma solidity ^0.8.0;


contract Util is Ownable {

    uint donateMin = 0.2 ether;
    uint donateMax = 2 ether;

    struct Account {
        address inviter;
        address[] invitees;
    }
    mapping (address => Account) public accounts;

    struct Donation {
        address sender;
        uint    amount;
    }
    Donation[] public donations;


    constructor(){}

    event Bind(address indexed inviter, address indexed invitee);
    event Donate(address indexed sender, uint indexed amount);


    function bind(address inviter) external {

        require(inviter != address(0), "not zero account");
        require(inviter != msg.sender, "can not be yourself");
        require(accounts[msg.sender].inviter == address(0), "already bind");

        accounts[msg.sender].inviter = inviter;
        accounts[inviter].invitees.push(msg.sender);
        emit Bind(inviter, msg.sender);
    }


    receive() external payable {
        donate();
    }

    function donate() payable public{
        require(msg.value >= 0.2 ether);
        require(msg.value <= 2 ether);

        donations.push(Donation(msg.sender, msg.value));
        emit Donate(msg.sender, msg.value);
    }

    function withdraw(address payable recipient, uint amount) external onlyOwner {
        recipient.transfer(amount);
    }


    function getDonateLimit() external view returns(uint max, uint min) {
        return (donateMax, donateMin);
    }

    function setDonateLimit(uint max, uint min) external onlyOwner () {
        donateMax = max;
        donateMin = min;
    }

    function getInvitation(address user) external view returns(address inviter, address[] memory invitees) {
        return (accounts[user].inviter, accounts[user].invitees);
    }

}