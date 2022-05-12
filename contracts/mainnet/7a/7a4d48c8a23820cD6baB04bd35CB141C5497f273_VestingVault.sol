//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IBEP20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

struct AllocationInput {
    address receiver;
    uint256 amount;
    bool revocable;
}

/**
 * @dev BEP20 Vesting contract. Releases the tokens linearly over the duration `VESTING_TERM`.
 * Paid out every `PAYOUT_RATE`.
 *
 * Allocations are added by the owner by transferring the tokens to the contract. These will be
 * vested over the full duration. Allocations can be revocable, returning the tokens to the owner.
 *
 */
contract VestingVault is Ownable {
    event AllocationAdded(address indexed receiver, uint256 amount, bool revocable);
    event AllocationModified(address indexed receiver, uint256 amount, bool revocable);

    struct Allocation {
        uint256 amount;
        uint256 claimed;
        bool revocable;
    }

    IBEP20 public token;

    uint256 public VESTING_TERM = 183 days;
    uint256 public PAYOUT_RATE = 1 days;

    uint256 public vestingStartDate;
    uint256 public vestingEndDate;

    mapping(address => Allocation) public allocations;

    constructor(IBEP20 _token, uint256 _startDate) {
        require(_startDate >= block.timestamp, 'start date cannot lie in the past');
        token = _token;
        vestingStartDate = _startDate;
        vestingEndDate = vestingStartDate + VESTING_TERM;
    }

    // -------- view -------

    /**
     * @dev Returns the amount that is claimable by caller.
     */
    function claimableAmount(address receiver) external view returns (uint256) {
        Allocation storage allocation = allocations[receiver];

        return calculateReward(allocation.amount, allocation.claimed);
    }

    /**
     * @dev Calculates the reward amount
     */
    function calculateReward(uint256 amount, uint256 claimed) public view returns (uint256) {
        if (block.timestamp < vestingStartDate) return 0;

        uint256 timeDelta = block.timestamp - vestingStartDate;
        timeDelta = (timeDelta / PAYOUT_RATE) * PAYOUT_RATE;

        if (timeDelta > VESTING_TERM) timeDelta = VESTING_TERM;

        uint256 totalPayout = (amount * timeDelta) / VESTING_TERM;

        return totalPayout - claimed;
    }

    // -------- user api -------

    /**
     * @dev Invokes the claim to the tokens calculated by `claimableAmount`.
     *
     * Throws if receiver does not have any allocation, or no tokens to claim.
     * Throws on token transfer failure.
     */
    function claim() external {
        Allocation storage allocation = allocations[msg.sender];

        uint256 reward = calculateReward(allocation.amount, allocation.claimed);
        require(reward > 0, 'no tokens to claim');

        allocation.claimed += reward;
        require(token.transfer(msg.sender, reward), 'could not transfer token');
    }

    // -------- admin -------

    /**
     * @dev Creates an allocation of `amount` to `receiver`.
     * `revocable` determines whether this allocation can be revoked by the owner.
     *
     * Requirements:
     *  - can only be called before `vestingStartDate`
     *  - `amount` must be greater 0
     *  - allocation must not override previous allocation
     */
    function addAllocation(
        address receiver,
        uint256 amount,
        bool _revocable
    ) public onlyOwner {
        Allocation storage allocation = allocations[receiver];

        require(allocation.amount == 0, 'cannot overwrite previous allocation');
        require(amount > 0, 'amount must be greater 0');

        allocation.amount = amount;
        allocation.revocable = _revocable;

        require(token.transferFrom(msg.sender, address(this), amount), 'could not transfer token');

        emit AllocationAdded(receiver, amount, _revocable);
    }

    /**
     * @dev Creates allocations in batches
     */
    function addAllocationBatch(AllocationInput[] memory _allocations) external onlyOwner {
        for (uint256 i; i < _allocations.length; i++) {
            AllocationInput memory allocation = _allocations[i];
            addAllocation(allocation.receiver, allocation.amount, allocation.revocable);
        }
    }

    function modifyAllocation(
        address receiver,
        uint256 amount,
        bool _revocable
    ) external onlyOwner onlyBeforeStart {
        Allocation storage allocation = allocations[receiver];

        require(allocation.amount != 0, 'no allocation found');
        require(amount > 0, 'amount must be greater 0');

        uint256 oldAmount = allocation.amount;

        if (amount > oldAmount) {
            uint256 additional = amount - oldAmount;
            require(token.transferFrom(msg.sender, address(this), additional), 'could not transfer token');
        } else {
            uint256 surplus = oldAmount - amount;
            require(token.transfer(msg.sender, surplus), 'could not transfer token');
        }

        allocation.amount = amount;
        allocation.revocable = _revocable;

        emit AllocationModified(receiver, amount, _revocable);
    }

    /**
     * @dev Revokes allowance to a claim on allocation.
     * `revocable` determines whether this allocation can be revoked by the owner.
     *
     * Requirements:
     *  - allocation must be revocable
     */
    function revokeAllowance(address receiver) external onlyOwner {
        Allocation storage allocation = allocations[receiver];

        require(allocation.revocable, 'allocation is not revocable');

        uint256 claimableReceiver = calculateReward(allocation.amount, allocation.claimed);
        uint256 remainderOwner = allocation.amount - claimableReceiver;

        allocation.amount = 0;
        allocation.revocable = false;

        if (claimableReceiver > 0) {
            allocation.claimed += claimableReceiver; // could delete for gas refund
            require(token.transfer(receiver, claimableReceiver), 'could not transfer token');
        }

        require(token.transfer(msg.sender, remainderOwner), 'could not transfer token');
    }

    /**
     * @dev Removes the ability of the owner to revoke this allocation.
     */
    function removeRevocability(address receiver) external onlyOwner {
        Allocation storage allocation = allocations[receiver];

        require(allocation.revocable, 'allocation already unable to be revoked');

        allocation.revocable = false;
    }

    /**
     * @dev Allows for tokens that were accidentally sent to the contract to be withdrawn.
     * Cannot be called for the token used for vesting.
     */
    function withdrawToken(IBEP20 _token) external onlyOwner {
        require(_token != token, 'cannot withdraw vault token');
        uint256 balance = _token.balanceOf(address(this));
        bool _success = _token.transfer(owner(), balance);
        require(_success, 'BEP20 Token could not be transferred');
    }

    // -------- modifier --------

    modifier onlyBeforeStart() {
        require(block.timestamp < vestingStartDate, 'must be before start date');
        _;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

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