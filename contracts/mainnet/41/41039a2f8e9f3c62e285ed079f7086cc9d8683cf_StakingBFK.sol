/**
 *Submitted for verification at BscScan.com on 2022-10-27
*/

// Sources flattened with hardhat v2.11.2 https://hardhat.org

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

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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


// File @openzeppelin/contracts/security/[email protected]

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


// File @openzeppelin/contracts/token/ERC20/[email protected]

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


// File contracts/BNBContract/StakingBFK.sol

pragma solidity ^0.8.0;



contract StakingBFK is ReentrancyGuard, Ownable {
    struct Staking {
        uint256 amount;
        uint256 lockFrom;
        uint256 lockTo;
    }

    struct Apr {
        uint256 rate;
        uint256 changedAt;
    }

    uint256 private daysSlotOne = 15;
    uint256 private daysSlotTwo = 45;
    uint256 private daysSlotThree = 90;
    uint256 private feeBeforeLockingPeriodOver = 5000;
    uint256 private feeAfterLockingPeriodOver = 400;
    uint256 private constant PERCENTAGE_DENOMINATOR = 10000;
    uint256 private constant YEAR_IN_SECONDS = 365 days; 

    uint256 public totalUsersAmount;
    address private adminWallet;
    IERC20 private token;

    mapping(uint256 => Apr[]) private aprHistory;
    mapping(address => Staking) private stakeHolders;

    event Stake(
        address user,
        uint256 amount,
        uint256 totalDays,
        uint256 timestamp
    );
    event Unstake(address user, uint256 amount, uint256 timestamp);
    event ChangeAPR(uint256 newApr, uint256 daysSlot);
    event ChangeWithdrawBeforeLockingFee(uint256 oldFee, uint256 newFee);
    event ChangeWithdrawAfterLockingFee(uint256 oldFee, uint256 newFee);
    event ChangeStakingPeriod(uint256 oldDays, uint256 newDays);

    constructor(address _adminWallet, IERC20 _token) {
        require(_adminWallet != address(0), "Invalid admin address!");
        require(address(_token) != address(0), "Invalid token address");
        token = _token;
        adminWallet = _adminWallet;

        aprHistory[daysSlotOne].push(Apr(1100, block.timestamp));
        aprHistory[daysSlotTwo].push(Apr(4320, block.timestamp));
        aprHistory[daysSlotThree].push(Apr(10000, block.timestamp));
    }

    /**
        @notice Owner can change the APR percentage
        by the giving new value as an input. 
        */
    function setAprInterest(uint256 _newApr, uint256 _daysSlot)
        external
        onlyOwner
    {
        require(
            _daysSlot == daysSlotOne ||
                _daysSlot == daysSlotTwo ||
                _daysSlot == daysSlotThree,
            "Invalid days slot!"
        );
        require(
            _newApr >= 1000 && // 10% minimum
                _newApr <= 250000, // 2500% maximum
            "Limit not met!"
        );
        require(
            _newApr !=
                aprHistory[_daysSlot][aprHistory[_daysSlot].length - 1].rate,
            "APR already set!"
        );
        aprHistory[_daysSlot].push(Apr(_newApr, block.timestamp));

        emit ChangeAPR(_newApr, _daysSlot);
    }

    /**
        @dev Owner can able to change the fee percentages by giving the new values
        to the args and giving old values again if don't need any change.
        */
    function setFeePercentage(uint256 _newFeeBeforeLockingPeriodOver)
        external
        onlyOwner
    {
        require(
            _newFeeBeforeLockingPeriodOver > 0 &&
                _newFeeBeforeLockingPeriodOver <= 5000,
            "Invalid fee percentage!"
        );
        require(
            _newFeeBeforeLockingPeriodOver != feeBeforeLockingPeriodOver,
            "Fee already set"
        );

        uint256 _oldFee = feeBeforeLockingPeriodOver;
        feeBeforeLockingPeriodOver = _newFeeBeforeLockingPeriodOver;

        emit ChangeWithdrawBeforeLockingFee(
            _oldFee,
            _newFeeBeforeLockingPeriodOver
        );
    }

    /**
        @notice Owner can change the 9% which is charged when user unstake
        tokens after that staking period is over, Owner cannot change more than
        the total of 4% fee.
        */
    function setFeeOnUnstake(uint256 _newFeeAfterLockingPeriodOver)
        external
        onlyOwner
    {
        require(
            _newFeeAfterLockingPeriodOver > 0 &&
                _newFeeAfterLockingPeriodOver <= 400,
            "Invalid fee allocation!"
        );
        require(
            _newFeeAfterLockingPeriodOver != feeAfterLockingPeriodOver,
            "Fee already set!"
        );
        uint256 _oldFee = feeAfterLockingPeriodOver;
        feeAfterLockingPeriodOver = _newFeeAfterLockingPeriodOver;

        emit ChangeWithdrawAfterLockingFee(
            _oldFee,
            _newFeeAfterLockingPeriodOver
        );
    }

    /**
        @notice Owner can change the staking days
        for all the three slots, Initally the slots are
        of 7, 30 and 90 days.
        */
    function changeStakingPeriod(
        uint256 _newDaysSlotOne,
        uint256 _newDaysSlotTwo,
        uint256 _newDaysSlotThree
    ) external onlyOwner {
        require(
            _newDaysSlotOne != 0 &&
                _newDaysSlotTwo != 0 &&
                _newDaysSlotThree != 0,
            "Days should be non-zero!"
        );
        require(
            _newDaysSlotOne != daysSlotOne ||
                _newDaysSlotTwo != daysSlotTwo ||
                _newDaysSlotThree != daysSlotThree,
            "Values must be different!"
        );

        uint256 _prevDays;
        if (_newDaysSlotOne != daysSlotOne) {
            _prevDays = daysSlotOne;
            aprHistory[_newDaysSlotOne].push(
                aprHistory[daysSlotOne][aprHistory[daysSlotOne].length - 1]
            );
            daysSlotOne = _newDaysSlotOne;

            emit ChangeStakingPeriod(_prevDays, _newDaysSlotOne);
        }
        if (_newDaysSlotTwo != daysSlotTwo) {
            _prevDays = daysSlotTwo;
            aprHistory[_newDaysSlotTwo].push(
                aprHistory[daysSlotTwo][aprHistory[daysSlotTwo].length - 1]
            );
            daysSlotTwo = _newDaysSlotTwo;

            emit ChangeStakingPeriod(_prevDays, _newDaysSlotTwo);
        }
        if (_newDaysSlotThree != daysSlotThree) {
            _prevDays = daysSlotThree;
            aprHistory[_newDaysSlotThree].push(
                aprHistory[daysSlotThree][aprHistory[daysSlotThree].length - 1]
            );
            daysSlotThree = _newDaysSlotThree;

            emit ChangeStakingPeriod(_prevDays, _newDaysSlotThree);
        }
    }

    /**
        @notice User can stake their tokens by calling this function.
        @param _amount Amount of tokens to stake
        @param _days No. of days for staking, Eg -> 7, 30 or 90 days
        */
    function stake(uint256 _amount, uint256 _days) external nonReentrant {
        require(_amount != 0, "Cannot stake zero amount!");
        require(
            _days == daysSlotOne ||
                _days == daysSlotTwo ||
                _days == daysSlotThree,
            "Invalid staking days!"
        );
        address _caller = msg.sender;
        require(stakeHolders[_caller].amount == 0, "Already a stakeholder!");

        uint256 _startTime = block.timestamp;
        uint256 _endTime = _startTime + (_days * 1 days);

        totalUsersAmount += _amount;
        stakeHolders[_caller] = Staking({
            amount: _amount,
            lockFrom: _startTime,
            lockTo: _endTime
        });

        require(
            token.transferFrom(_caller, address(this), _amount),
            "ERC20 operation did not succeed"
        );

        emit Stake(_caller, _amount, _days, _startTime);
    }

    /**
        @notice User can unstake their tokens by calling this function
        The user may charged some fee based on the number of days he 
        has staked tokens to.
        */
    function unstake() external nonReentrant {
        address _caller = msg.sender;
        require(stakeHolders[_caller].amount != 0, "Not a stakeholder!");

        Staking memory _userStaking = stakeHolders[_caller];
        uint256 _userPayableAmount;

        if (block.timestamp <= _userStaking.lockTo)
            _userPayableAmount = _distributeFee(_userStaking.amount);
        else _userPayableAmount = _unstake(_caller);

        totalUsersAmount -= stakeHolders[_caller].amount;
        delete stakeHolders[_caller];
        _transferTokens(_caller, _userPayableAmount);

        emit Unstake(_caller, _userPayableAmount, block.timestamp);
    }

    /**
        @notice Users can view the details of staking by passing their address
        @param _user Address of the user
        */
    function viewStake(address _user) external view returns (Staking memory) {
        return stakeHolders[_user];
    }

    /**
        @notice It will return the total tokens for rewards available 
        in the contract.
        */
    function totalRewards() external view returns (uint256) {
        return (token.balanceOf(address(this)) - totalUsersAmount);
    }

    /**
        @notice View the currently set APR for the specific days slot.
        @param _daysSlot days slot for the current APR
        */
    function getCurrentAPR(uint256 _daysSlot) external view returns (uint256) {
        require(
            _daysSlot == daysSlotOne
            || _daysSlot == daysSlotTwo
            || _daysSlot == daysSlotThree,
            "Invalid days!"
        );
        // require(aprHistory[_daysSlot].length > 0, "Invalid days slot!");
        return aprHistory[_daysSlot][aprHistory[_daysSlot].length - 1].rate;
    }

    /// @dev Private function for unstake called the external 'stake()' function
    function _unstake(address _user)
        private
        returns (
            // ! Naming Convention
            uint256 _amountToWithdraw
        )
    {
        // Final amount to withdraw
        uint256 _totalAmount = _getReturnGenerated(_user); /// Calculating Amount on APRs

        // Deducting 4% fee on Unstaking
        uint256 _feeAmount = (_totalAmount * feeAfterLockingPeriodOver) /
            PERCENTAGE_DENOMINATOR;
        _transferTokens(adminWallet, _feeAmount);

        // Final payable amount to user
        _amountToWithdraw = _totalAmount - _feeAmount;
    }

    /// @dev Private function for fee distribution
    function _distributeFee(uint256 _amount)
        private
        returns (uint256 _userPayableAmount)
    {
        uint256 _feeAmount = (_amount * feeBeforeLockingPeriodOver) /
            PERCENTAGE_DENOMINATOR;
        _transferTokens(adminWallet, _feeAmount);

        return (_amount - _feeAmount);
    }

    function _transferTokens(address _receiver, uint256 _amount) private {
        require(
            token.transfer(_receiver, _amount),
            "ERC20 operation did not succeed"
        );
    }

    function _getReturnGenerated(address _user) private view returns (uint256) {
        Staking memory _stake = stakeHolders[_user];
        uint256 _daysSlot = (_stake.lockTo - _stake.lockFrom) / (1 days); 
        uint256 _interest;
        uint256 _length = aprHistory[_daysSlot].length;
        uint256 _rewardPerSec;

        if (_length == 1) {
            _rewardPerSec =
                ((_stake.amount * aprHistory[_daysSlot][0].rate) /
                    PERCENTAGE_DENOMINATOR) /
                YEAR_IN_SECONDS; 
            return
                _stake.amount +
                (_rewardPerSec * (_stake.lockTo - _stake.lockFrom));
        }
        if (_stake.lockFrom >= aprHistory[_daysSlot][_length - 1].changedAt) {
            _rewardPerSec =
                ((_stake.amount * aprHistory[_daysSlot][_length - 1].rate) /
                    PERCENTAGE_DENOMINATOR) /
                YEAR_IN_SECONDS; 
            return
                _stake.amount +
                (_rewardPerSec * (_stake.lockTo - _stake.lockFrom));
        }

        uint256 _timeDiff;
        bool _flag;

        for (uint256 index = 1; index < _length; index++) {
            Apr memory _apr = aprHistory[_daysSlot][index];
            Apr memory _prevApr = aprHistory[_daysSlot][index - 1];

            if (_stake.lockFrom < _apr.changedAt) {
                if (_stake.lockFrom >= _prevApr.changedAt) {
                    if (_stake.lockTo <= _apr.changedAt) {
                        _timeDiff = _stake.lockTo - _stake.lockFrom;
                        _flag = true;
                    } else {
                        _timeDiff = _apr.changedAt - _stake.lockFrom;
                        if (index == (_length - 1)) {
                            _rewardPerSec =
                                ((_stake.amount * _apr.rate) /
                                    PERCENTAGE_DENOMINATOR) /
                                YEAR_IN_SECONDS; 
                            _interest += ((_stake.lockTo - _apr.changedAt) *
                                _rewardPerSec);
                            _flag = true;
                        }
                    }
                } else if (
                    _stake.lockFrom < _prevApr.changedAt &&
                    _stake.lockTo > _apr.changedAt
                ) {
                    _timeDiff = _apr.changedAt - _prevApr.changedAt;
                    if (index == (_length - 1)) {
                        _rewardPerSec =
                            ((_stake.amount * _apr.rate) /
                                PERCENTAGE_DENOMINATOR) /
                            YEAR_IN_SECONDS;
                        _interest += ((_stake.lockTo - _apr.changedAt) *
                            _rewardPerSec);
                        _flag = true;
                    }
                } else {
                    _timeDiff = _stake.lockTo - _prevApr.changedAt;
                    _flag = true;
                }

                _rewardPerSec =
                    ((_stake.amount * _prevApr.rate) / PERCENTAGE_DENOMINATOR) /
                    YEAR_IN_SECONDS;
                _interest += (_timeDiff * _rewardPerSec);
                if (_flag) break;
            }
        }
        return _stake.amount + _interest;
    }
}