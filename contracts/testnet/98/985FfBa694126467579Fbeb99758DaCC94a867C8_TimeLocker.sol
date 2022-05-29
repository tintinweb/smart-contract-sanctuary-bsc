// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TimeLocker is Ownable {
    IERC20 public token;

    struct TimeLock {
        uint256 balance;
        uint256 startDate;
        uint256 cliffDate;
        uint256[] periods;
        uint256 released;
        bool revoked;
        bool valid;
    }

    mapping(address => TimeLock) public timeLocks;

    constructor(
        address tokenContract,
        uint256 start,
        uint256 cliff,
        address[] memory beneficiaries,
        uint256[] memory amount,
        uint256[] memory periods
    ) {
        token = IERC20(tokenContract);

        for (uint256 i = 0; i < beneficiaries.length; i += 1) {
            TimeLock memory tl;

            tl.balance = uint256(amount[i]);
            tl.startDate = start;
            tl.cliffDate = cliff;
            tl.periods = periods;
            tl.valid = true;

            timeLocks[beneficiaries[i]] = tl;
        }
    }

    event Vest(address beneficiary, uint256 amount, uint256 releaseTime);
    event Release(address beneficiary, uint256 amount);
    event Revoked(address beneficiary, uint256 remaining);

    function vest(
        uint256 amount,
        uint256 start,
        uint256 cliff,
        uint256[] calldata periods
    ) public virtual returns (bool) {
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Error Transfer"
        );
        require(!timeLocks[msg.sender].valid, "Already vesting");

        TimeLock memory tl;

        tl.balance = amount;
        tl.startDate = start;
        tl.cliffDate = tl.startDate + cliff;
        tl.periods = periods;
        tl.valid = true;

        timeLocks[msg.sender] = tl;

        emit Vest(msg.sender, amount, periods[periods.length - 1]);

        return true;
    }

    function release() public virtual returns (bool) {
        TimeLock memory tl = timeLocks[msg.sender];

        uint256 vested = vestedAmount(tl, uint64(block.timestamp));

        emit Release(msg.sender, vested);
        require(token.transfer(msg.sender, vested), "Error Transfer");
        return true;
    }

    function revoke(address beneficiary) public onlyOwner returns (bool) {
        TimeLock memory tl = timeLocks[beneficiary];
        uint256 remaining = _vestingSchedule(tl, uint64(block.timestamp));

        tl.revoked = true;
        timeLocks[beneficiary] = tl;

        emit Revoked(beneficiary, remaining);

        if (remaining > 0) {
            require(token.transfer(msg.sender, remaining), "Error Transfer");
        }

        return true;
    }

    function vestedAmount(TimeLock memory tl, uint64 timestamp)
        internal
        view
        returns (uint256)
    {
        return _vestingSchedule(tl, timestamp) + tl.released;
    }

    function vestedAmount(address beneficiary) public view returns (uint256) {
        TimeLock memory tl = timeLocks[beneficiary];
        return _vestingSchedule(tl, uint64(block.timestamp)) + tl.released;
    }

    function _vestingSchedule(TimeLock memory tl, uint64 timestamp)
        internal
        view
        virtual
        returns (uint256)
    {
        if (timestamp < tl.startDate || tl.revoked) {
            return 0;
        }

        uint256 pLen = tl.periods.length;
        uint256 lastPeriod = tl.periods[pLen - 1];

        if (timestamp > lastPeriod) {
            return tl.balance - tl.released;
        } else {
            uint256 period;
            uint256 count = 0;

            while (timestamp > period) {
                period = tl.periods[count];
            }

            uint256 vested = (tl.balance * count) / tl.periods.length;

            return vested - tl.released;
        }
    }

    // function depositOld(
    //     address beneficiary,
    //     uint256 amount,
    //     uint256 releaseTime
    // ) public returns (bool success) {
    //     require(
    //         token.transferFrom(msg.sender, address(this), amount),
    //         "Error Transfer"
    //     );

    //     TimeLock memory tl;
    //     tl.beneficiary = beneficiary;
    //     tl.balance = amount;
    //     tl.releaseTime = releaseTime;
    //     lockBoxStructs.push(l);

    //     timeLocks[beneficiary] = tl;

    //     emit TimeLockDeposit(msg.sender, amount, releaseTime);
    //     return true;
    // }

    // function withdrawOld() public returns (bool success) {
    //     TimeLock storage tl = timeLocks[msg.sender];

    //     uint256 amount = tl.balance;
    //     tl.balance = 0;

    //     emit TimeLockWithdrawal(msg.sender, amount);
    //     require(token.transfer(msg.sender, amount), "Error Transfer");
    //     return true;
    // }
}

// SPDX-License-Identifier: MIT
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