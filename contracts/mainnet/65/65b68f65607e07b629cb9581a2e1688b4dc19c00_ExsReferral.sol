/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

// SPDX-License-Identifier: None

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.13;

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

// File: ExsReferral.sol


pragma solidity ^0.8.13;


contract ExsReferral is Ownable{
    mapping (uint32=>address) private _codesReferrals;
    mapping (address=>uint32) private _referralCodes;
    mapping (address=>bool) private _registeredReferrals;
    uint32 private _referralCodeBase = 127543; // max uint32 value 4,294,967,295
    uint32 private _codesCount;

    modifier onlyIfRegistered(){
        require(isRegistered(msg.sender)==true, "This account is not a referral");
        _;
    }
    modifier onlyIfNotRegistered(){
        require(isRegistered(msg.sender)==false, "This account is already a referral");
        _;
    }

    function getReferralCode(address account)
        public
        view
        returns(uint32)
    {
        return _referralCodes[account];
    }
    function getReferralAddress(uint32 code)
        public
        view
        returns(address)
    {
        return _codesReferrals[code];
    }
    
    function register()
        external
        onlyIfNotRegistered
    {
        _codesCount+=1;
        uint32 code=_referralCodeBase+_codesCount;
        _codesReferrals[code]=msg.sender;
        _referralCodes[msg.sender]=code;
        _registeredReferrals[msg.sender]=true;
    }
    function unregister()
        external
        onlyIfRegistered
    {
        _codesReferrals[_referralCodes[msg.sender]]=address(0);
        _referralCodes[msg.sender]=0;
        _registeredReferrals[msg.sender]=false;
    }

    function removeReferralFromAccount(address account)
        external
        onlyOwner
    {
        _registeredReferrals[account]=false;
        _codesReferrals[_referralCodes[account]]=address(0);
        _referralCodes[account]=0;
    }
    function removeReferralFromCode(uint32 code)
        external
        onlyOwner
    {
        _registeredReferrals[_codesReferrals[code]]=false;
        _referralCodes[_codesReferrals[code]]=0;
        _codesReferrals[code]=address(0);
    }

    function isRegistered(address account)
        public
        view
        returns(bool)
    {
        return(_registeredReferrals[account]);
    }
}