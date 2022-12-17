/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: contracts/TokenLocker.sol

//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;



contract TokenLocker {
    using Counters for Counters.Counter;

    struct Lock {
        uint256 lockId;
        address tokenContract;
        address locker;
        uint256 amount;
        uint256 unlockTime;
        bool withdrawn;
    }

    Counters.Counter private _lockedLocksNumber;
    Counters.Counter private _unlockedLocksNumber;
    Lock[] private _allLocks;

    event TokensLocked(
        uint256 lockId,
        address tokenContract,
        address locker,
        uint256 amount,
        uint256 unlockTime
    );

    event TokensUnlocked(
        uint256 lockId,
        address tokenContract,
        address locker,
        uint256 amount
    );

    function lockTokens(
        address tokenContract,
        uint256 amount,
        uint256 timeInHours
    ) public {
        IERC20(tokenContract).transferFrom(msg.sender, address(this), amount);
        uint256 unlockTime = block.timestamp + timeInHours * 1 hours;
        uint256 currentLockId = _lockedLocksNumber.current();
        _allLocks.push(
            Lock(
                currentLockId,
                tokenContract,
                msg.sender,
                amount,
                unlockTime,
                false
            )
        );
        _lockedLocksNumber.increment();
        emit TokensLocked(
            currentLockId,
            tokenContract,
            msg.sender,
            amount,
            unlockTime
        );
    }

    function withdrawTokens(address tokenContract, uint256 lockId) public {
        Lock memory lock = _allLocks[lockId];
        require(lock.locker == msg.sender, "you are not owner of tokens!");
        require(lock.withdrawn == false, "you already withdrawn your tokens!");
        require(lock.unlockTime < block.timestamp, "you must wait for unlock!");
        _allLocks[lockId].withdrawn = true;
        _unlockedLocksNumber.increment();
        IERC20(tokenContract).transfer(msg.sender, lock.amount);
        emit TokensUnlocked(lockId, tokenContract, msg.sender, lock.amount);
    }

    /* --- Getters --- */

    function getAllActiveLocks() public view returns (Lock[] memory) {
        uint256 activeLocksNumber = _lockedLocksNumber.current() -
            _unlockedLocksNumber.current();
        Lock[] memory activeLocks = new Lock[](activeLocksNumber);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < _lockedLocksNumber.current(); i++) {
            if (_allLocks[i].withdrawn == false) {
                activeLocks[currentIndex] = _allLocks[i];
                currentIndex++;
            }
        }
        return activeLocks;
    }

    function getMyActiveLocks() public view returns (Lock[] memory) {
        uint256 activeLocksCounter = 0;
        for (uint256 i = 0; i < _lockedLocksNumber.current(); i++) {
            if (
                _allLocks[i].withdrawn == false &&
                _allLocks[i].locker == msg.sender
            ) {
                activeLocksCounter++;
            }
        }
        Lock[] memory myActiveLocks = new Lock[](activeLocksCounter);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < _lockedLocksNumber.current(); i++) {
            if (
                _allLocks[i].withdrawn == false &&
                _allLocks[i].locker == msg.sender
            ) {
                myActiveLocks[currentIndex] = _allLocks[i];
                currentIndex++;
            }
        }
        return myActiveLocks;
    }
}