pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Interface/IDeepToken.sol";
import "./Interface/IDKeeperEscrow.sol";

contract AirDrop is Ownable {
    // Info of each user.
    struct UserInfo {
        uint256 alloc;
        uint256 rewardDebt;
    }

    // DeepToken contract
    IDeepToken public deepToken;

    // DKeeper Escrow contract
    IDKeeperEscrow public dKeeperEscrow;

    // Timestamp of last reward
    uint256 public lastRewardTime;

    // Accumulated token per share
    uint256 public accTokenPerShare;

    // Info of each user that stakes LP tokens.
    mapping(address => UserInfo) public userInfo;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;

    // The block number when Deep distribution starts.
    uint256 public startTime;

    // The block number when Deep distribution ends.
    uint256 public endTime;

    uint256 public constant WEEK = 3600 * 24 * 7;

    event Claimed(address indexed user, uint256 amount);

    constructor(
        IDeepToken _deep,
        uint256 _startTime,
        uint256 _endTime
    ) public {
        require(_endTime >= _startTime && block.timestamp <= _startTime, "Invalid timestamp");
        deepToken = _deep;
        startTime = _startTime;
        endTime = _endTime;

        totalAllocPoint = 0;
        lastRewardTime = _startTime;
    }

    // View function to see pending Deeps on frontend.
    function pendingDeep(address _user) external view returns (uint256) {
        UserInfo memory user = userInfo[_user];

        uint256 updatedAccTokenPerShare = accTokenPerShare;
        if (block.timestamp > lastRewardTime && totalAllocPoint != 0) {
            uint256 rewards = getRewards(lastRewardTime, block.timestamp);
            updatedAccTokenPerShare += ((rewards * 1e6) / totalAllocPoint);
        }

        return (user.alloc * updatedAccTokenPerShare) / 1e6 - user.rewardDebt;
    }

    // Update reward variables to be up-to-date.
    function updatePool() public {
        if (block.timestamp <= lastRewardTime || lastRewardTime >= endTime) {
            return;
        }
        if (totalAllocPoint == 0) {
            lastRewardTime = block.timestamp;
            return;
        }

        uint256 rewards = getRewards(lastRewardTime, block.timestamp);

        accTokenPerShare = accTokenPerShare + ((rewards * 1e6) / totalAllocPoint);
        lastRewardTime = block.timestamp;
    }

    // Claim rewards.
    function claim() public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.alloc != 0, "Not allocated with this account.");
        updatePool();

        uint256 pending = (user.alloc * accTokenPerShare) / 1e6 - user.rewardDebt;
        if (pending > 0) {
            safeDeepTransfer(msg.sender, pending);
            emit Claimed(msg.sender, pending);
        }

        user.rewardDebt = (user.alloc * accTokenPerShare) / 1e6;
    }

    // Safe DEEP transfer function, just in case if rounding error causes pool to not have enough DEEP
    function safeDeepTransfer(address _to, uint256 _amount) internal {
        dKeeperEscrow.mint(_to, _amount);
    }

    // Get rewards between block timestamps
    function getRewards(uint256 _from, uint256 _to) internal view returns (uint256 rewards) {
        while (_from + WEEK <= _to) {
            rewards += getRewardRatio(_from) * WEEK;
            _from = _from + WEEK;
        }

        if (_from + WEEK > _to) {
            rewards += getRewardRatio(_from) * (_to - _from);
        }
    }

    // Get rewardRatio from timestamp
    function getRewardRatio(uint256 _time) internal view returns (uint256) {
        if (8 < (_time - startTime) / WEEK) return 0;

        return (((2e24 * (8 - (_time - startTime) / WEEK)) / 8 / 35) * 10) / WEEK;
    }

    ///////////////////////
    /// Owner Functions ///
    ///////////////////////
    function addAirdropWallets(address[] memory _accounts, uint256[] memory _allocs)
        external
        onlyOwner
    {
        require(_accounts.length == _allocs.length && _allocs.length != 0, "Invalid array length");

        for (uint8 i = 0; i < _allocs.length; i++) {
            require(_accounts[i] != address(0), "Invalid address");
            require(_allocs[i] != 0 && _allocs[i] <= 10, "Invalid allocation number");
            require(userInfo[_accounts[i]].alloc == 0, "Already added");

            userInfo[_accounts[i]] = UserInfo(_allocs[i], 0);
            totalAllocPoint += _allocs[i];
        }
    }

    function removeAirdropWallets(address[] memory _accounts) external onlyOwner {
        require(_accounts.length != 0, "Invalid array length");

        for (uint8 i = 0; i < _accounts.length; i++) {
            require(_accounts[i] != address(0), "Invalid address");
            require(userInfo[_accounts[i]].alloc != 0, "Not added to airdrop list");

            totalAllocPoint -= userInfo[_accounts[i]].alloc;

            delete userInfo[_accounts[i]];
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDeepToken is IERC20 {
    function mint(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity 0.8.4;

interface IDKeeperEscrow {
    function mint(address account, uint256 amount) external;
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