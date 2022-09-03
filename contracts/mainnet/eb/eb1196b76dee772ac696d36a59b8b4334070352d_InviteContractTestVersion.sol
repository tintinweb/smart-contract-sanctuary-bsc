/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactionInfos the account sending and
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

interface StakeContract {
    function getUserTotalDepositAmount(address addr) external view returns (uint256);
}

contract InviteContractTestVersion is Ownable {
    address public stakeContract;
    address public firstInviter;
    mapping(address => address) public referrals;
    mapping(address => address[]) public InviteeAddress;

    event Bind(address indexed _invitee,address indexed _inviter);
    event ResetReferrals(address indexed _invitee,address indexed _inviter);
    event SetFirstReferral(address indexed _firstInvitee, address indexed _firstInviter);

    constructor() {
        firstInviter = 0x410bC60e4c137F345b6c7332438Eb3B8d0c1c6E1;
    }

    function bind(address _inviter) public {
        require(_inviter != address(0),"bind: Input address is a zero address");
        require(referrals[msg.sender] == address(0),"bind: This account has been bound to an inviter");
        require(_inviter != msg.sender,"bind: The inviter cannot be yourself");
        require(referrals[_inviter] != msg.sender,"bind: Inviter cannot be your own invitees");
        require(StakeContract(stakeContract).getUserTotalDepositAmount(_inviter) > 0, "bind: The user is an invalid user");
        referrals[msg.sender] = _inviter;
        InviteeAddress[_inviter].push(msg.sender);
        emit Bind(msg.sender,_inviter);
    }

    function setFirstReferral(address firstInvitee) public onlyOwner {
        referrals[firstInvitee] = firstInviter;
        InviteeAddress[firstInviter].push(firstInvitee);
        emit SetFirstReferral(firstInvitee, firstInviter);
    }

    function setStakeContract(address _contractAddress) public onlyOwner {
        stakeContract = _contractAddress;
    }

    function setFirstInviter(address _addr) public onlyOwner {
        firstInviter = _addr;
    }

    function getMyInviter(address _addr) public view returns(address) {
        return referrals[_addr];
    }

    function getMyInviteeAddress(address _addr) public view returns (address[] memory) {
        return InviteeAddress[_addr];
    }
}