// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BinanceStakingClub is Ownable, ReentrancyGuard {

	struct Staking {
        address from;
        uint amount;
        bool isAutoCompound;
        uint8 numberOfMonths;
        uint64 stakingTimestamp;
        bool lockedWithEarlyWithdrawal;
        uint64 earlyWithdrawalLockedTimestamp;
        bool lockedWithProfitWithdrawal;
        uint64 profitWithdrawalLockedTimestamp;
        uint profitWithdrawalRequested;
        uint totalProfitWithdrawn;
        bool isFinished;
    }

    struct Profile { 
        uint totalNumberOfStakings;
        mapping(uint => Staking) stakings;
    }

    mapping(address => Profile) public profile;

    event StakedEvent(address indexed from, uint amount, bool isAutoCompound, uint8 numberOfMonths, uint timestamp);
    event EarlyLockupRequestEvent(address indexed from, uint numberOfStaking, uint timestamp);
    event EarlyLockupWithdrawalEvent(address indexed from, uint numberOfStaking, uint withdrawnAmount, uint timestamp);
    event RegularWithdrawalEvent(address indexed from, uint numberOfStaking, uint withdrawnAmount, uint timestamp);
    event ProfitWithdrawalRequestEvent(address indexed from, uint numberOfStaking, uint requestedAmount, uint timestamp);
    event ProfitWithdrawalEvent(address indexed from, uint numberOfStaking, uint requestedAmount, uint timestamp);

    function stake(uint8 numberOfMonths, bool isAutoCompound) external payable returns(uint) {
      require(msg.value >= 200000000000000000, "Mininmum staking amount is 0.2 BNB");
      Staking memory stakings = Staking(
          _msgSender(),
          msg.value,
          isAutoCompound,
          numberOfMonths,
          uint64(block.timestamp),
          false,
          0,
          false,
          0,
          0,
          0,
          false
      );
      uint numberOfStaking = profile[_msgSender()].totalNumberOfStakings;
      profile[_msgSender()].stakings[numberOfStaking] = stakings;
      numberOfStaking++;
      profile[_msgSender()].totalNumberOfStakings = numberOfStaking;
  
      emit StakedEvent(_msgSender(), msg.value, isAutoCompound, numberOfMonths, block.timestamp);

      return msg.value;
    }

    function withdrawAll() payable external onlyOwner {
        address payable to = payable(_msgSender());
        address thisContract = address(this);
        (bool success, ) = to.call{value:thisContract.balance}("");
        require(success, "Transfer failed.");
    }

    function transfer(address payable to, uint256 amount) external nonReentrant onlyOwner {
        require(address(this).balance >= amount,  'Transfer amount exceeds balance');
        
        (bool success, ) = to.call{value:amount}("");
        require(success, "Transfer failed.");
    }

    // Checking for early withdrawal

    function isEarlyWithdrawal (Staking memory staking) internal view returns (bool) {
        return block.timestamp < staking.stakingTimestamp + (30 days) * staking.numberOfMonths; 
    }

    // Checking for unlock time to pass for early withdrawal

    function isEarlyWithdrawalRequestLocked (Staking memory staking) internal view returns (bool) {
        return block.timestamp < staking.earlyWithdrawalLockedTimestamp + 3 days; 
    }

    // Checking for unlock time to pass for early withdrawal

    function isProfitWithdrawalRequestLocked (Staking memory staking) internal view returns (bool) {
        return block.timestamp < staking.profitWithdrawalLockedTimestamp + 1 days; 
    }

    // Getting staking by number

    function getStakingByNumber(uint numberOfStaking) internal view returns (Staking memory) {
        return profile[_msgSender()].stakings[numberOfStaking];
    }

    // Withdrawal handlers

    // Early lockup request

    function earlyLockupRequest(uint numberOfStaking) external {
        Staking memory staking = getStakingByNumber(numberOfStaking);
        require(staking.isFinished == false, 'This staking is finished');
        require(staking.lockedWithEarlyWithdrawal == false, 'This staking is locked with early withdrawal');
        require(staking.lockedWithProfitWithdrawal == false, 'This staking is locked with profit withdrawal');
        require(isEarlyWithdrawal(staking) == true, 'This staking is not for early lockup');
        staking.earlyWithdrawalLockedTimestamp = uint64(block.timestamp);
        staking.lockedWithEarlyWithdrawal = true;
        profile[_msgSender()].stakings[numberOfStaking] = staking;
        emit EarlyLockupRequestEvent(_msgSender(), numberOfStaking, block.timestamp);
    }

    // Early lockup withdrawal

    function earlyLockupWithdrawal(uint numberOfStaking) external payable {
        Staking memory staking = getStakingByNumber(numberOfStaking);
        require(staking.isFinished == false, 'This staking is finished');
        require(staking.lockedWithEarlyWithdrawal == true, 'This staking should be locked with early withdrawal');
        require(staking.lockedWithProfitWithdrawal == false, 'This staking is locked with profit withdrawal');
        require(isEarlyWithdrawalRequestLocked(staking) == false, 'Time for early lockup hasn`t pass');
        uint withdrawAmount = profitAmountCalculation(numberOfStaking) + staking.amount;

        address payable to = payable(_msgSender());
        (bool success, ) = to.call{value:withdrawAmount}("");
        require(success, "Transfer failed.");

        staking.isFinished = true;
        profile[_msgSender()].stakings[numberOfStaking] = staking;
        emit EarlyLockupWithdrawalEvent(_msgSender(), numberOfStaking, withdrawAmount, block.timestamp);
    }

    // Withdrawal after lockup ended

    function regularWithdrawal(uint numberOfStaking) external payable {
        Staking memory staking = getStakingByNumber(numberOfStaking);
        require(staking.isFinished == false, 'This staking is finished');
        require(staking.lockedWithEarlyWithdrawal == false, 'This staking should be locked with early withdrawal');
        require(staking.lockedWithProfitWithdrawal == false, 'This staking is locked with profit withdrawal');
        require(isEarlyWithdrawal(staking) == false, 'This staking is for early lockup only');
        uint withdrawAmount = profitAmountCalculation(numberOfStaking) + staking.amount;
        
        address payable to = payable(_msgSender());
        (bool success, ) = to.call{value:withdrawAmount}("");
        require(success, "Transfer failed.");

        staking.isFinished = true;
        profile[_msgSender()].stakings[numberOfStaking] = staking;
        emit RegularWithdrawalEvent(_msgSender(), numberOfStaking, withdrawAmount, block.timestamp);
    }

    // Profit withdrawal request

    function profitWithdrawalRequest(uint numberOfStaking, uint requestedAmount) external {
        Staking memory staking = getStakingByNumber(numberOfStaking);
        require(staking.isFinished == false, 'This staking is finished');
        require(staking.lockedWithEarlyWithdrawal == false, 'This staking is locked with early withdrawal');
        require(staking.lockedWithProfitWithdrawal == false, 'This staking is locked with profit withdrawal');
        require(staking.isAutoCompound == false, 'Can`t withdraw profit from staking with auto-compound');
        uint profitAvailable = profitAmountCalculation(numberOfStaking);
        require(profitAvailable >= requestedAmount, 'Requested amount is bigger than available profit');
        staking.profitWithdrawalLockedTimestamp = uint64(block.timestamp);
        staking.lockedWithProfitWithdrawal = true;
        staking.profitWithdrawalRequested = requestedAmount;
        profile[_msgSender()].stakings[numberOfStaking] = staking;
        emit ProfitWithdrawalRequestEvent(_msgSender(), numberOfStaking, requestedAmount, block.timestamp);
    }

    // Profit withdrawal

    function profitWithdrawal(uint numberOfStaking) external {
        Staking memory staking = getStakingByNumber(numberOfStaking);
        require(staking.isFinished == false, 'This staking is finished');
        require(staking.lockedWithEarlyWithdrawal == false, 'This staking is locked with early withdrawal');
        require(staking.lockedWithProfitWithdrawal == true, 'This staking should be locked with profit withdrawal');
        require(isProfitWithdrawalRequestLocked(staking) == false, 'Time for early lockup hasn`t pass');

        address payable to = payable(_msgSender());
        (bool success, ) = to.call{value:staking.profitWithdrawalRequested}("");
        require(success, "Transfer failed.");
        staking.totalProfitWithdrawn += staking.profitWithdrawalRequested;
        staking.lockedWithProfitWithdrawal = false;
        profile[_msgSender()].stakings[numberOfStaking] = staking;
        emit ProfitWithdrawalEvent(_msgSender(), numberOfStaking, staking.profitWithdrawalRequested, block.timestamp);
    }

    // Counting available profit for each staking

    function profitAmountCalculation(uint numberOfStaking) internal view returns (uint) {
        Staking memory staking = getStakingByNumber(numberOfStaking);
        bool isAutoCompound = staking.isAutoCompound;
        uint8 monthsLockup = staking.numberOfMonths;
        uint amount = staking.amount;
        uint64 stakingTimestamp = staking.stakingTimestamp;
        bool lockedWithEarlyWithdrawal = staking.lockedWithEarlyWithdrawal;
        uint64 earlyWithdrawalLockedTimestamp = staking.earlyWithdrawalLockedTimestamp;
        uint totalProfitWithdrawn = staking.totalProfitWithdrawn;

        // If early lockup requested, staking finishes at early lockup timestamp

        uint64 stakingFinishTimestamp;
        if (lockedWithEarlyWithdrawal) {
            stakingFinishTimestamp = earlyWithdrawalLockedTimestamp;
        } else {
            stakingFinishTimestamp = uint64(block.timestamp);
        }

        // Days passed from staking start to finish

        uint64 daysDiff = (stakingFinishTimestamp - stakingTimestamp) / 60 / 60 / 24;

        // Profit per day coefficient calculation 

        uint64 coefficient;
        if (monthsLockup < 6) {
            coefficient = 2;
        } else if (monthsLockup < 12) {
            coefficient = 4;
        } else {
            coefficient = 6;
        }

        // Penalty fee for early withdrawal calculation

        uint8 lockupFeeCoefficient;
        if (lockedWithEarlyWithdrawal) {
            lockupFeeCoefficient = 9;
        } else {
            lockupFeeCoefficient = 10;
        }

        // Withrawal amount calculation for auto-compound option enabled/disabled

        uint availableWithdrawalAmount;
        if (isAutoCompound) {
            availableWithdrawalAmount = amount * (1 + coefficient / 1000) ** daysDiff - amount;
        } else {
            availableWithdrawalAmount = amount * daysDiff * coefficient * lockupFeeCoefficient  / 10000;
        }

        // Reducing previous profit withdrawns

        availableWithdrawalAmount -= totalProfitWithdrawn;
        
        return availableWithdrawalAmount;
    }

    function getStakingByNumberTest(uint numberOfStaking) public view returns (Staking memory) {
        return profile[_msgSender()].stakings[numberOfStaking];
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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