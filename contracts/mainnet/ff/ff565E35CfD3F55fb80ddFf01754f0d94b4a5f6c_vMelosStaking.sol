//SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IVMelos} from "./IVMelos.sol";

interface IMelosRewards {
    function rewardTime() external view returns (uint256);
}

contract vMelosStaking is OwnableUpgradeable {
    IERC20 public melos;
    IVMelos public vMelos;
    address public melos_reward;
    uint256 public constant RATE_BASE = 100;

    bool public paused;

    address[] public activeUsers;

    // four pool
    enum Pool {
        ONE,
        THREE,
        SIX,
        TWELVE
    }
    // pool info
    struct PoolInfo {
        uint256 apy; // apy
        uint256 period; //  time amount
        uint256 devider; // apy / devider = period apy
        uint256 amounts; // deposit amount
    }

    struct UserInfo {
        Pool pool; // pool
        uint256 index; // active_users_index
        uint256 startTime; // start deposit block time
        uint256 amounts; // deposit amount
        uint256 pendingReward; //
        uint256 lastRewardTime; // last upreward block
        uint256 rewards; // has benn acculated rewards
    }

    mapping(address => UserInfo) public userInfos;
    mapping(Pool => PoolInfo) public poolInfos;

    event Deposit(address indexed user, Pool indexed pool, uint256 amount, uint256 timestamp);
    event ReDeposit(address indexed user, Pool indexed pool, uint256 amount, uint256 timestamp);
    event ExitPool(address indexed user, Pool indexed pool, uint256 amount, uint256 timestamp);
    event ClaimRewards(address indexed user, uint256 amount, uint256 timestamp);
    event UpgradePool(address indexed user, Pool old_pool, Pool new_pool, uint256 timestamp);
    event EmergencyWithdraw(address indexed user, Pool indexed pool, uint256 amount);

    function initialize(
        address _melos,
        address _vMelos,
        address _reward
    ) external initializer {
        require(_melos != address(0) && _vMelos != address(0) && _reward != address(0), "zero address");
        __Ownable_init();
        melos_reward = _reward;
        melos = IERC20(_melos);
        vMelos = IVMelos(_vMelos);
        _initApy();
    }

    function _initApy() internal {
        poolInfos[Pool.ONE] = PoolInfo(30, 30 days, 12, 0);
        poolInfos[Pool.THREE] = PoolInfo(50, 90 days, 4, 0);
        poolInfos[Pool.SIX] = PoolInfo(90, 180 days, 2, 0);
        poolInfos[Pool.TWELVE] = PoolInfo(130, 360 days, 1, 0);
    }

    // test
    // function _initApy() internal {
    //     poolInfos[Pool.ONE] = PoolInfo(30, 30 minutes, 12, 0);
    //     poolInfos[Pool.THREE] = PoolInfo(50, 90 minutes, 4, 0);
    //     poolInfos[Pool.SIX] = PoolInfo(90, 180 minutes, 2, 0);
    //     poolInfos[Pool.TWELVE] = PoolInfo(130, 360 minutes, 1, 0);
    // }

    ///////<<<<---------------  user interface  start  ----------->>>>>///////
    function deposit(Pool pool, uint256 amount) external {
        // 1 check condition
        require(!paused, "paused");
        require(amount > 0, "zero amount");
        assert(uint256(pool) <= 3); //optional
        address user = msg.sender;
        // 2 check deposit
        // new deposit
        if (userInfos[user].amounts == 0) {
            userInfos[user].pool = pool;
            userInfos[user].startTime = block.timestamp;
            // new user
            if (userInfos[user].rewards == 0) {
                userInfos[user].index = activeUsers.length;
                activeUsers.push(user);
            }
            updateReward(pool, user);
        } else {
            // pool must matched
            require(userInfos[user].pool == pool, "unmatched pool");
            // has not ended
            require(block.timestamp < userInfos[user].startTime + poolInfos[pool].period, "pool is ended");
            updateReward(pool, user);
        }

        // 3 transfer token
        melos.transferFrom(msg.sender, address(this), amount);
        // 4 mint mVelos
        vMelos.depositFor(msg.sender, amount);
        // 5 update amount
        userInfos[msg.sender].amounts += amount;
        poolInfos[pool].amounts += amount;
        // max limit 2**96/1e18 = 79,228,162,514  //vMelos safe96 limit;
        // optional
        // require(getAllDepositAmounts() < 2**96,"deposit max limit");
        // 6 emit event
        emit Deposit(msg.sender, pool, amount, block.timestamp);
    }

    function prolongTo(Pool new_pool) external {
        require(!paused, "paused");
        assert(uint256(new_pool) <= 3); //optional
        address user = msg.sender;
        // must deposited
        uint256 amount = userInfos[user].amounts;
        require(amount > 0, "no deposit");
        Pool old_pool = userInfos[user].pool;
        // must upgrade, not down
        require(uint256(old_pool) < uint256(new_pool), "new pool must gt old pool");
        // not ended
        require(block.timestamp < userInfos[user].startTime + poolInfos[old_pool].period, "pool is ended");
        // update reward
        updateReward(old_pool, user);
        // upgrade
        poolInfos[old_pool].amounts -= amount;
        userInfos[user].pool = new_pool;
        poolInfos[new_pool].amounts += amount;
        emit UpgradePool(user, old_pool, new_pool, block.timestamp);
    }

    function withdraw() external {
        address user = msg.sender;
        uint256 amount = userInfos[user].amounts;
        // must deposit
        require(amount > 0, "no deposit");
        Pool pool = userInfos[user].pool;
        //has ended
        require(block.timestamp >= userInfos[user].startTime + poolInfos[pool].period, "pool is not ended");
        updateReward(pool, user);
        userInfos[user].amounts -= amount;
        assert(userInfos[user].amounts == 0); // optional
        poolInfos[pool].amounts -= amount;
        melos.transfer(user, amount);
        // burn vMelos
        vMelos.withdrawTo(user, amount);
        // check active user;
        if (userInfos[user].rewards == 0) {
            _removeUser(user);
        }
        emit ExitPool(user, pool, amount, block.timestamp);
    }

    // re deposit after end
    function redeposit(Pool pool) external {
        require(!paused, "paused");
        address user = msg.sender;
        UserInfo memory info = userInfos[user];
        require(info.amounts > 0, "not deposited");
        require(block.timestamp > info.startTime + poolInfos[info.pool].period, "pool not ended");
        updateReward(info.pool, user);

        // new deposit
        userInfos[user].startTime = block.timestamp;
        userInfos[user].amounts = 0; // mock exit
        if (info.pool != pool) {
            // update pool
            poolInfos[info.pool].amounts -= info.amounts;
            poolInfos[pool].amounts += info.amounts;
            userInfos[user].pool = pool;
        }

        updateReward(pool, user);
        userInfos[user].amounts = info.amounts;

        emit ReDeposit(user, pool, info.amounts, block.timestamp);
    }

    // optional
    function emergencyWithdraw() external {
        address user = msg.sender;
        uint256 amount = userInfos[user].amounts;
        // must deposit
        require(amount > 0, "no deposit");
        Pool pool = userInfos[user].pool;
        //has ended
        require(block.timestamp >= userInfos[user].startTime + poolInfos[pool].period, "pool is not ended");
        userInfos[user].amounts = 0;
        melos.transfer(user, amount);
        // burn vMelos
        vMelos.withdrawTo(user, amount);
        _removeUser(user);
        delete userInfos[user];
        emit EmergencyWithdraw(user, pool, amount);
    }

    function claimRewards() external {
        address user = msg.sender;
        uint256 rewardTime = IMelosRewards(melos_reward).rewardTime();
        require(block.timestamp >= rewardTime && rewardTime != 0, "must after rewardTime");
        // upgrade rewards
        if (userInfos[user].amounts > 0) {
            updateReward(userInfos[user].pool, user);
        }
        uint256 claim_amounts = 0;
        // has ended,claim all rewards
        if (userInfos[user].lastRewardTime < rewardTime) {
            claim_amounts = userInfos[user].rewards;
            require(claim_amounts > 0, "no rewards");
            // transfer all rewards
            userInfos[user].rewards -= claim_amounts;
            userInfos[user].pendingReward = 0;
            assert(userInfos[user].rewards == 0); // optional
            melos.transferFrom(melos_reward, user, claim_amounts);
        } else {
            // claim pending rewards
            claim_amounts = userInfos[user].pendingReward;
            require(claim_amounts > 0, "no claimable rewards");
            assert(userInfos[user].rewards >= claim_amounts); // optional
            userInfos[user].rewards -= claim_amounts;
            userInfos[user].pendingReward -= claim_amounts;
            assert(userInfos[user].pendingReward == 0); // optional
            melos.transferFrom(melos_reward, user, claim_amounts);
        }
        // remove exit pool user
        if (userInfos[user].amounts == 0 && userInfos[user].rewards == 0) {
            _removeUser(user);
        }
        emit ClaimRewards(user, claim_amounts, block.timestamp);
    }

    // get pending rewards; only calculate at timestamp of futher
    function _getUserPendingRewards(address user, uint256 rewardTime) internal view returns (uint256) {
        UserInfo memory user_info = userInfos[user];
        if (user_info.lastRewardTime >= rewardTime) {
            // has updated
            return user_info.pendingReward;
        } else {
            // mock updated
            PoolInfo memory info = poolInfos[user_info.pool];
            uint256 end = info.period + user_info.startTime;
            uint256 delta = getMin(rewardTime, end) - user_info.lastRewardTime;
            if (delta == 0) {
                // has recorded
                return user_info.rewards;
            } else {
                uint256 pending = (user_info.amounts * delta * info.apy) / (RATE_BASE * info.period * info.devider);
                return user_info.rewards + pending;
            }
        }
    }

    // get latest claimable rewards
    function getUserPendingRewards(address user) external view returns (uint256) {
        uint256 rewardTime = IMelosRewards(melos_reward).rewardTime();
        if (rewardTime == 0) {
            return 0;
        }
        return _getUserPendingRewards(user, rewardTime);
    }

    /////   admin interface   ////
    // get all pending rewards of user
    function getUsersPendingRewards(address[] calldata users, uint256 rewardTime) external view returns (uint256) {
        uint256 old_time = IMelosRewards(melos_reward).rewardTime();
        require(rewardTime >= old_time, "can't get pendingRewards before latest rewardTime");
        uint256 sum = 0;
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            sum += _getUserPendingRewards(user, rewardTime);
        }
        return sum;
    }

    // get all
    function getAllUsersPendingRewards(uint256 rewardTime) external view returns (uint256) {
        uint256 old_time = IMelosRewards(melos_reward).rewardTime();
        require(rewardTime >= old_time, "can't get pendingRewards before latest rewardTime");
        uint256 sum = 0;
        for (uint256 i = 0; i < activeUsers.length; i++) {
            address user = activeUsers[i];
            sum += _getUserPendingRewards(user, rewardTime);
        }
        return sum;
    }

    function _getUserRewards(address user, uint256 blockTime) internal view returns (uint256) {
        UserInfo memory user_info = userInfos[user];
        if (user_info.amounts == 0) {
            return user_info.rewards;
        } else {
            PoolInfo memory info = poolInfos[user_info.pool];
            uint256 end = info.period + user_info.startTime;
            uint256 delta = getMin(blockTime, end) - user_info.lastRewardTime;
            if (delta == 0) {
                // has recorded
                return user_info.rewards;
            } else {
                uint256 pending = (user_info.amounts * delta * info.apy) / (RATE_BASE * info.period * info.devider);
                return user_info.rewards + pending;
            }
        }
    }

    // get user reward
    function getUserRewards(address user) external view returns (uint256) {
        return _getUserRewards(user, block.timestamp);
    }

    // get user rewards(include pending) at future block
    function getUserRewards(address user, uint256 block_time) external view returns (uint256) {
        require(block_time >= block.timestamp, "must after now");
        return _getUserRewards(user, block_time);
    }

    // get by page at current block
    function getUsersRewards(address[] calldata users) external view returns (uint256) {
        uint256 block_time = block.timestamp;
        uint256 sum = 0;
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            sum += _getUserRewards(user, block_time);
        }
        return sum;
    }

    // get by page at future block
    function getUsersRewards(address[] calldata users, uint256 block_time) external view returns (uint256) {
        require(block_time >= block.timestamp, "must after now");
        uint256 sum = 0;
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            sum += _getUserRewards(user, block_time);
        }
        return sum;
    }

    // get all rewards on current block
    function getAllUsersRewards() external view returns (uint256) {
        uint256 block_time = block.timestamp;
        uint256 sum = 0;
        for (uint256 i = 0; i < activeUsers.length; i++) {
            address user = activeUsers[i];
            sum += _getUserRewards(user, block_time);
        }
        return sum;
    }

    // get all on future block
    function getAllUsersRewards(uint256 block_time) external view returns (uint256) {
        require(block_time >= block.timestamp, "must after now");
        uint256 sum = 0;
        for (uint256 i = 0; i < activeUsers.length; i++) {
            address user = activeUsers[i];
            sum += _getUserRewards(user, block_time);
        }
        return sum;
    }

    // get all
    function getActiveUsers() external view returns (address[] memory) {
        return activeUsers;
    }

    // get length
    function getActiveUsersLength() external view returns (uint256) {
        return activeUsers.length;
    }

    // get by page
    function getUsersInfos(address[] calldata users) external view returns (UserInfo[] memory results) {
        results = new UserInfo[](users.length);
        for (uint256 i = 0; i < users.length; i++) {
            results[i] = userInfos[users[i]];
        }
    }

    // get all user info
    function getAllUsersInfos() external view returns (UserInfo[] memory results) {
        results = new UserInfo[](activeUsers.length);
        for (uint256 i = 0; i < activeUsers.length; i++) {
            results[i] = userInfos[activeUsers[i]];
        }
    }

    // get all deposit amounts
    function getTotalLockAmounts() public view returns (uint256 result) {
        result =
            poolInfos[Pool.ONE].amounts +
            poolInfos[Pool.THREE].amounts +
            poolInfos[Pool.SIX].amounts +
            poolInfos[Pool.TWELVE].amounts;
    }

    function getAverageLockTime() public view returns (uint256 avgTime) {
        uint256 weightedTotal = 0;
        uint256 total = 0;
        PoolInfo storage p1 = poolInfos[Pool.ONE];
        total += p1.amounts;
        weightedTotal += p1.amounts * p1.period;

        PoolInfo storage p3 = poolInfos[Pool.THREE];
        total += p3.amounts;
        weightedTotal += p3.amounts * p3.period;

        PoolInfo storage p6 = poolInfos[Pool.SIX];
        total += p6.amounts;
        weightedTotal += p6.amounts * p6.period;

        PoolInfo storage p12 = poolInfos[Pool.TWELVE];
        total += p12.amounts;
        weightedTotal += p12.amounts * p12.period;

        avgTime = weightedTotal / total;
    }

    function pause() external onlyOwner {
        require(!paused, "paused");
        paused = true;
    }

    function unpause() external onlyOwner {
        require(paused, "unpaused");
        paused = false;
    }

    /////  internal interface   //////
    function updateReward(Pool pool, address user) internal {
        // 100% can run
        uint256 rewardTime = 0;
        try IMelosRewards(melos_reward).rewardTime() returns (uint256 v) {
            rewardTime = v;
        } catch {
            // skip
        }
        UserInfo memory user_info = userInfos[user];
        PoolInfo memory info = poolInfos[pool];
        uint256 end = info.period + user_info.startTime;
        uint256 min_time = getMin(block.timestamp, end);
        uint256 delta = min_time - user_info.lastRewardTime;
        if (delta == 0) {
            // has recorded or has ended
            return;
        }
        if (user_info.lastRewardTime < rewardTime && rewardTime <= min_time) {
            // update last pending rewards
            uint256 pending_reward = (user_info.amounts * (rewardTime - user_info.lastRewardTime) * info.apy) /
                (RATE_BASE * info.period * info.devider);
            userInfos[user].pendingReward = userInfos[user].rewards + pending_reward;
        }

        uint256 rewards = (user_info.amounts * delta * info.apy) / (RATE_BASE * info.period * info.devider);
        // update
        userInfos[user].rewards += rewards;
        userInfos[user].lastRewardTime = min_time;
    }

    function _removeUser(address user) internal {
        uint256 index = userInfos[user].index;
        address last = activeUsers[activeUsers.length - 1];
        if (user != last) {
            activeUsers[index] = last;
            userInfos[last].index = index;
        }
        activeUsers.pop();
    }

    function getMin(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
pragma solidity ^0.8.0;

interface IVMelos {
    /**
     * @dev Emitted when an account changes their delegate.
     */
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /**
     * @dev Emitted when a token transfer or delegate change results in changes to a delegate's number of votes.
     */
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /**
     * @dev Returns the current amount of votes that `account` has.
     */
    function getVotes(address account) external view returns (uint256);

    /**
     * @dev Returns the amount of votes that `account` had at the end of a past block (`blockNumber`).
     */
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256);

    /**
     * @dev Returns the total supply of votes available at the end of a past block (`blockNumber`).
     *
     * NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes.
     * Votes that have not been delegated are still part of total supply, even though they would not participate in a
     * vote.
     */
    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256);

    /**
     * @dev Returns the total voters at the end of a past block (`blockNumber`).
     */
    function getPastVoters(uint256 blockNumber) external view returns (uint256);

    /**
     * @dev Returns the delegate that `account` has chosen.
     */
    function delegates(address account) external view returns (address);

    /**
     * @dev Delegates votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) external;

    /**
     * @dev Delegates votes from signer to `delegatee`.
     */
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Allow a user to deposit underlying tokens and mint the corresponding number of wrapped tokens.
     */
    function depositFor(address account, uint256 amount) external returns (bool);

    /**
     * @dev Allow a user to burn a number of wrapped tokens and withdraw the corresponding number of underlying tokens.
     */
    function withdrawTo(address account, uint256 amount) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}