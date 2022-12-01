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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MDRStaking is Ownable {
    uint256 public startBlock;
    uint256 public blockRate;
    IERC20 public mdr = IERC20(0x3E9a178e2a20112A086c0a9C340Baf83ddB0d209);
    IERC20 public busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    uint256 blockTime = 3;

    struct UserInfo {
        uint256 amount; // How much mdr is staked
        uint256 rewardDebt; 
    }

    struct PoolInfo {
        uint256 lastRewardBlock;
        uint256 accRewardPerShare; 
    }

    PoolInfo public pool;
    mapping (address => UserInfo) userInfo;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor() {
        blockRate = 5000 ether / (1 days * 30 * 3 / blockTime);
        startBlock = block.timestamp;
    }

    function setMdr(address _mdr) external onlyOwner {
        mdr = IERC20(_mdr);
    }

    function setBusd(address _busd) external onlyOwner {
        busd = IERC20(_busd);
    }

    function deposit(uint256 _amount) external {
        updatePool();
        UserInfo storage user = userInfo[_msgSender()];
        if(user.amount > 0) {
            uint256 pending = user.amount * pool.accRewardPerShare / 1e12 - user.rewardDebt;
            if(pending > 0) {
                busd.transfer(_msgSender(), pending);
            }
        }
        if(_amount > 0) {
            mdr.transferFrom(_msgSender(), address(this), _amount);
            user.amount = user.amount + _amount;
        }
        user.rewardDebt = user.amount * pool.accRewardPerShare / 1e12;
        emit Deposit(_msgSender(), _amount);
    }

    function withdraw(uint256 _amount) external {
        UserInfo storage user = userInfo[_msgSender()];
        require(user.amount >= _amount, "Withdraw: not good");
        updatePool();
        uint256 pending = user.amount * pool.accRewardPerShare / 1e12 - user.rewardDebt;
        if(pending > 0) {
            busd.transfer(_msgSender(), pending);
        }
        if(_amount > 0) {
            user.amount = user.amount - _amount;
            mdr.transfer(_msgSender(), _amount);
        }
        user.rewardDebt = user.amount * pool.accRewardPerShare / 1e12;
        emit Withdraw(_msgSender(), _amount);
    }

    function updatePool() public {
        if(block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 supply = mdr.balanceOf(address(this));
        if(supply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 reward = blockRate * (block.number - pool.lastRewardBlock);
        pool.lastRewardBlock = block.number;
        pool.accRewardPerShare = pool.accRewardPerShare + reward * 1e12 / supply;
    }

    function setStartBlock(uint256 _startBlock) public onlyOwner {
        require(startBlock > block.number, "Invalid Start Time");
        startBlock = _startBlock;
    }

    function pendingBusd(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 accPerSahre = pool.accRewardPerShare;
        uint256 supply = mdr.balanceOf(address(this));
        if(block.number > pool.lastRewardBlock && supply != 0) {
            uint reward = blockRate * (block.number - pool.lastRewardBlock);
            accPerSahre = accPerSahre + reward * 1e12 / supply;
        }
        return user.amount * accPerSahre / 1e12 - user.rewardDebt;
    }

    function emergencyWithdraw() public {
        UserInfo storage user = userInfo[_msgSender()];
        mdr.transfer(msg.sender, user.amount);
        emit EmergencyWithdraw(msg.sender, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

}