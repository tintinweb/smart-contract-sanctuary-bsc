/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

// File: contracts/TransferHelper.sol



pragma solidity ^0.8.9;


// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
// File: contracts/IStrtVesting.sol



pragma solidity ^0.8.9;

interface IStrtVesting {
    function tge() external returns (uint256);
}

// File: contracts/ISTRTXCREO.sol



pragma solidity ^0.8.9;

interface ISTRTXCREO {
    function checkTgeStatus(address) external view returns(bool);
    function userTotalLocks(address) external view returns(uint256);
}

// File: contracts/StrtLocking.sol



pragma solidity ^0.8.9;






contract StrtLocking is Ownable {
    mapping(address => LockInfo[]) public userLocks;
    mapping(address => uint256) public userTotalLocks;

    struct LockInfo {
        uint256 startLockTime;
        uint256 lockedValue;
        bool strtUnlocked;
        uint256 lockReleaseTime;
    }

    uint256 public strtLockBegin = 1649605866; // CHANGEME // Sunday, April 10, 2022 10:51:06 PM GMT+07:00
    uint256 public strtLockEnd = 99999999999999; // CHANGEME
    uint256 public strtLockDuration;
    uint256 public minimumStrtLock;
    uint256 public maximumStrtLock;

    address public strtToken;
    address public vesting; 

    constructor(uint256 _strtLockDuration, uint256 _minimumStrtLock, uint256 _maximumStrtLock, address _strtToken) {
        strtLockDuration = _strtLockDuration;
        minimumStrtLock = _minimumStrtLock;
        maximumStrtLock = _maximumStrtLock;
        strtToken = _strtToken;
    }

    /**
     * @dev Records data of all the tokens Locked
     */
    event Locked(
        address indexed _of,
        uint256 _amount,
        uint256 _validity
    );

    /**
     * @dev Records data of all the tokens unlocked
     */
    event Unlocked(
        address indexed _of,
        uint256 _index,
        uint256 _amount
    );

    /**
     * @dev Set locking period
     * @param _begin Beginning time
     * @param _end End time
     */
    function setLockBeginEnd(uint256 _begin, uint256 _end) external onlyOwner {
        strtLockBegin = _begin;
        strtLockEnd = _end;
    }

    /**
     * @dev Set the minimum lock amount
     * @param _minLock Minimum number of tokens to be locked
     */
    function setMinimumStrtLock(uint256 _minLock) external onlyOwner {
        minimumStrtLock = _minLock;
    }

    /**
     * @dev Set the maximum lock amount
     * @param _maxLock Maximum number of tokens to be locked
     */
    function setMaximumStrtLock(uint256 _maxLock) external onlyOwner {
        maximumStrtLock = _maxLock;
    }

    /**
     * @dev Set the token's lock duration
     * @param _seconds Duration in seconds
     */
    function setStrtLockDuration(uint256 _seconds) external onlyOwner {
        strtLockDuration = _seconds;
    }

    /**
     * @dev Set the contract address for vesting
     * @param _vesting The contract address for vesting
     */
    function saveVestingAddress(address _vesting) external onlyOwner returns(bool) {
        vesting = _vesting;
        return true;
    }  

    /**
     * @dev Locks a specified amount of tokens against the sender
     * @param _value Number of tokens to be locked
     */
    function lock(uint256 _value) external {
        require(block.timestamp >= strtLockBegin && block.timestamp <= strtLockEnd, "Not in lock period.");
        require(vesting != address(0), "Vesting set to the zero address.");
        require(block.timestamp < IStrtVesting(vesting).tge(), "Not eligible.");
        require(_value >= minimumStrtLock, "Not enough to lock.");
        require(_value <= maximumStrtLock, "Exceed limit to lock.");
        require(IERC20(strtToken).allowance(msg.sender, address(this)) >= _value, "Allowance strt not enough");

        uint256 strtLockTime = block.timestamp;
        uint256 lockRelease = strtLockTime + strtLockDuration;
        
        userLocks[msg.sender].push(LockInfo(strtLockTime, _value, false, lockRelease));
        userTotalLocks[msg.sender] = userTotalLocks[msg.sender] + _value;
        TransferHelper.safeTransferFrom(strtToken, msg.sender, address(this), _value);

        emit Locked(msg.sender, _value, lockRelease);
    }

    /**
     * @dev Unlocks the unlockable tokens of the sender
     * @param _index The index to query the lock tokens for
     */
    function unlock(uint256 _index) external {
        require(!userLocks[msg.sender][_index].strtUnlocked, "Has been unlocked.");
        require(block.timestamp >= userLocks[msg.sender][_index].lockReleaseTime, "Can't be unlocked yet.");

        userLocks[msg.sender][_index].strtUnlocked = true;
        uint256 lockedValue = userLocks[msg.sender][_index].lockedValue;
        userTotalLocks[msg.sender] = userTotalLocks[msg.sender] - (lockedValue);
        TransferHelper.safeTransfer(strtToken, msg.sender, lockedValue);

        emit Unlocked(msg.sender, _index, lockedValue);
    }

    /**
     * @dev Returns tokens locked for a specified address for a
     *      specified index
     *
     * @param _of The address whose tokens are locked
     * @param _index The index to query the lock tokens for
     */
    function tokensLocked(address _of, uint256 _index)
        public
        view
        returns (uint256 amount)
    {
        if (!userLocks[_of][_index].strtUnlocked)
            amount = userLocks[_of][_index].lockedValue;
    }

    /**
     * @dev Returns unlockable tokens for a specified address for a specified index
     * @param _of The address to query the the unlockable token count of
     * @param _index The reason to query the unlockable tokens for
     */
    function tokensUnlockable(address _of, uint256 _index)
        public
        view
        returns (uint256 amount)
    {
        if (userLocks[_of][_index].lockReleaseTime <= block.timestamp && !userLocks[_of][_index].strtUnlocked)
            amount = userLocks[_of][_index].lockedValue;
    }
}