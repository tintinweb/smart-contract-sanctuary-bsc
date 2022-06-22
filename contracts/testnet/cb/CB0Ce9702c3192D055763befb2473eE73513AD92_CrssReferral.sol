// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ICrssReferral.sol";

contract CrssReferral is ICrssReferral, Ownable {
    mapping(address => address) public referrers; // user address => referrer address
    mapping(address => uint256) public countReferrals; // referrer address => referrals count
    mapping(address => uint256) public totalReferralCommissions; // referrer address => total referral commissions
    mapping(address => uint256) public outstandingCommissions;

    event ReferralRecorded(address indexed user, address indexed referrer);
    event ReferralCommissionRecorded(address indexed referrer, uint256 commission);
    event OperatorUpdated(address indexed operator, bool indexed status);

    address public payer;
    constructor() Ownable() {
    }

    function setPayer(address _payer) external onlyOwner {
        payer = _payer;
    }

    function recordReferral(address _user, address _referrer) public override {
        require( _msgSender() == payer, "Only payer can record referrers");
        referrers[_user] = _referrer;
        countReferrals[_referrer] += 1;
        emit ReferralRecorded(_user, _referrer);
    }

    function recordReferralCommission(address _referrer, uint256 _commission) public override {
        require( _msgSender() == payer, "Only payer can record commission");
        totalReferralCommissions[_referrer] += _commission;
        outstandingCommissions[_referrer] += _commission;
        emit ReferralCommissionRecorded(_referrer, _commission);
    }

    function getOutstandingCommission(address _referrer) external view override returns (uint256 amount) {
        amount = outstandingCommissions[_referrer];
    }

    function debitOutstandingCommission(address _referrer, uint256 _debit) external override {
        require( _msgSender() == payer, "Only payer can debit outstanding commission");
        outstandingCommissions[_referrer] -= _debit;
    }

    // Get the referrer address that referred the user
    function getReferrer(address _user) public view override returns (address) {
        return referrers[_user];
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

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

interface ICrssReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(address referrer, uint256 commission) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);

    function getOutstandingCommission(address _referrer) external view returns (uint256 amount);

    function debitOutstandingCommission(address _referrer, uint256 _debit) external;
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