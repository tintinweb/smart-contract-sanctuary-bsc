/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

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

// SPDX-License-Identifier: MIT
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

// File: contracts/bft/Invitation.sol

pragma solidity ^0.8.0;


contract Invitation02 is Ownable{

    bool public lock;
    struct Account {
        address inviter;
        address[] invitees;
    }
    mapping (address => Account) accounts;
    address constant root = 0x9295F2420176F8e2E9E2f0cDDb79F84426e281B8;
    address constant invitation01 = 0x1ed732A198f0e446Fc26e941ACc3e6Af46C948dA;


    event Bind(address indexed inviter, address indexed invitee);
    constructor(){}


    function bind (address inviter) external {
        require(inviter != address(0), "not zero account");
        require(inviter != msg.sender, "can not be yourself");
        _bind(inviter, msg.sender);
    }

    function invite (address invitee) external {
        require(!lock, "can not be called");
        require(invitee != root, "how dare you are");
        require(invitee != address(0), "not zero account");
        require(invitee != msg.sender, "can not be yourself");
        _bind(msg.sender, invitee);
    }

    function _bind (address inviter, address invitee) internal {

        (address inviter01,) = getInvitation(invitee);
        require(inviter01 == address(0), "already bind");

        if (accounts[inviter].inviter == address(0)) {
            if (!migrate(inviter)) {
                inviter = root;
            }
        }

        accounts[invitee].inviter = inviter;
        accounts[inviter].invitees.push(invitee);
        emit Bind(inviter, invitee);
    }

    function migrate (address account) public returns(bool){
        (address inviter, address[] memory invitees) = Invitation02(invitation01).getInvitation(account);
        if (inviter != address(0)) {
            accounts[account].inviter = inviter;
            accounts[account].invitees = invitees;
            return true;
        }
        return false;
    }

    function getInvitation(address user) public view returns(address inviter, address[] memory invitees) {
        inviter = accounts[user].inviter;
        if (inviter == address(0)) {
            (inviter,invitees) = Invitation02(invitation01).getInvitation(user);
        }else{
            invitees = accounts[user].invitees;
        }
    }

    function _accounts(address user) public view returns (address inviter, address[] memory invitees) {
        inviter = accounts[user].inviter;
        invitees = accounts[user].invitees;
    }

    function setLock(bool l) external onlyOwner {
        lock = l;
    }
}