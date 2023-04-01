/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

/**
 *Submitted for verification at BscScan.com on 2023-03-29
*/

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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

// File: ..\node_modules\@openzeppelin\contracts\utils\Context.sol
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

// File: @openzeppelin\contracts\access\Ownable.sol
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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

// File: contracts\TokenLockers.sol
pragma solidity ^0.8.0;

contract TokenLocker is Ownable {
    struct LockInfo {
        uint256 lockId;
        address owner;
        address tokenAddress;
        uint256 amount;
        uint256 lockDate;
        uint256 unlockDate;
    }

    uint256 public lockFee;
    uint256 public totalLockedTokens;
    uint256 public totalProjects;
    address public feeReceiver;
    uint256 public lockIdCounter;
    uint256 public totalFeesCollected;

    mapping(uint256 => LockInfo) public locks;
    mapping(address => mapping(address => uint256)) public userLocks;
    mapping(address => uint256) public totalLockedTokensByUser;

    event TokenLocked(
        uint256 lockId,
        address indexed user,
        address indexed tokenAddress,
        uint256 amount,
        uint256 unlockDate
    );
    event TokenUnlocked(
        uint256 lockId,
        address indexed user,
        address indexed tokenAddress,
        uint256 amount
    );
    event LockFeeUpdated(uint256 newLockFee);
    event FeeReceiverUpdated(address newFeeReceiver);
    event LockPeriodIncreased(
        uint256 lockId,
        address indexed user,
        uint256 newUnlockDate
    );

    constructor(uint256 _lockFee, address _feeReceiver) {
        lockFee = _lockFee;
        feeReceiver = _feeReceiver;
    }

    function lockTokens(
        address _tokenAddress,
        uint256 _amount,
        uint256 _unlockTimestamp
    ) external {
        IERC20 token = IERC20(_tokenAddress);

        // Collect lock fee
        require(lockFee > 0, "Lock fee should be greater than 0");
        require(
            token.transferFrom(msg.sender, feeReceiver, lockFee),
            "Failed to transfer lock fee"
        );

        totalFeesCollected += lockFee;

        // Transfer locked tokens
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );

        require(
            _unlockTimestamp > block.timestamp,
            "Unlock timestamp should be in the future"
        );

        lockIdCounter++;
        uint256 lockId = lockIdCounter;

        locks[lockId] = LockInfo(
            lockId,
            msg.sender,
            _tokenAddress,
            _amount,
            block.timestamp,
            _unlockTimestamp
        );
        userLocks[msg.sender][_tokenAddress] = lockId;

        totalLockedTokens += _amount;
        totalLockedTokensByUser[msg.sender] += _amount;
        totalProjects++;

        emit TokenLocked(
            lockId,
            msg.sender,
            _tokenAddress,
            _amount,
            _unlockTimestamp
        );
    }

    function unlockTokens(address _tokenAddress) external {
        uint256 _lockId = userLocks[msg.sender][_tokenAddress];
        require(_lockId != 0, "No locked tokens found for this address");

        LockInfo storage lockInfo = locks[_lockId];
        require(
            lockInfo.unlockDate <= block.timestamp,
            "Unlock date not reached"
        );
        require(msg.sender == lockInfo.owner, "Only the owner can unlock tokens");

        IERC20 token = IERC20(lockInfo.tokenAddress);
        token.transfer(msg.sender, lockInfo.amount);

        totalLockedTokens -= lockInfo.amount;
        totalLockedTokensByUser[msg.sender] -= lockInfo.amount;
            emit TokenUnlocked(
        _lockId,
        msg.sender,
        lockInfo.tokenAddress,
        lockInfo.amount
    );

    delete userLocks[msg.sender][_tokenAddress];
    delete locks[_lockId];
}

function setLockFee(uint256 _newLockFee) external onlyOwner {
    lockFee = _newLockFee;
    emit LockFeeUpdated(_newLockFee);
}

function setFeeReceiver(address _newFeeReceiver) external onlyOwner {
    feeReceiver = _newFeeReceiver;
    emit FeeReceiverUpdated(_newFeeReceiver);
}

function getLockInfoByTokenAddress(address _user, address _tokenAddress)
    public
    view
    returns (LockInfo memory)
{
    uint256 _lockId = userLocks[_user][_tokenAddress];
    return locks[_lockId];
}

function increaseLockDate(
    address _tokenAddress,
    uint256 _additionalAmount,
    uint256 _newUnlockTimestamp
) external {
    uint256 _lockId = userLocks[msg.sender][_tokenAddress];
    require(_lockId != 0, "No locked tokens found for this address");

    LockInfo storage lockInfo = locks[_lockId];
    require(msg.sender == lockInfo.owner, "Only the owner can modify the lock");
    require(
        _newUnlockTimestamp >= lockInfo.unlockDate,
        "New unlock timestamp should be equal or later than the current unlock date"
    );

    if (_additionalAmount > 0) {
        IERC20 token = IERC20(lockInfo.tokenAddress);
        require(
            token.transferFrom(msg.sender, address(this), _additionalAmount),
            "Failed to transfer additional tokens"
        );
        lockInfo.amount += _additionalAmount;
        totalLockedTokens += _additionalAmount;
        totalLockedTokensByUser[msg.sender] += _additionalAmount;
    }

    lockInfo.unlockDate = _newUnlockTimestamp;
    emit LockPeriodIncreased(_lockId, msg.sender, lockInfo.unlockDate);
}

function getTotalLockedTokensByUser(
    address _user
) public view returns (uint256) {
    return totalLockedTokensByUser[_user];
}
}