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

pragma solidity ^0.8.11;
// SPDX-License-Identifier: MIT
import '@openzeppelin/contracts/access/Ownable.sol';

interface IPancakePair {
    function initialize(address, address) external;

    function totalSupply() external view returns (uint256);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

contract PirateFlexStaking is Ownable {
    IERC20 public rewardToken;

    // Info of each user
    struct UserInfo {
        uint256 start;
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // This number always increases to counterwaight always increasing "accTokenPerShare"
        bool isStaking;
    }

    // Info of a pool
    struct PoolInfo {
        uint256 rate;
        uint256 lastRewardBlock; // Last block number that CAKEs distribution occurs.
        uint256 accTokenPerShare; // Accumulated CAKEs per share, times 1e12. See below.
        uint256 totalStaked;
        uint256 rewardPool;
        uint256 timePoolAdded;
        uint256 period;
    }

    PoolInfo public pool;
    mapping(address => UserInfo) public userInfo;
    uint256 public amountOfUsers = 0;

    event Stake(address indexed user, uint256 amount);
    event Unstake(address indexed user, uint256 amount);
    event ForceUnstake(address indexed user, uint256 amount);

    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
        _initPool();
    }

    /// @dev Receives tokens and sets parameters
    /// @param amount amount of staking tokens
    function stake(uint256 amount) external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount == 0, 'already staking');
        require(amount > 0, 'Nothing to stake');
        require(pool.rewardPool > 0, 'reward pool is empty'); // rates did not set
        updatePool();
        rewardToken.transferFrom(msg.sender, address(this), amount);
        pool.totalStaked += amount; // 2)
        userInfo[msg.sender] = UserInfo({
            start: block.timestamp,
            amount: amount,
            rewardDebt: ((amount * pool.accTokenPerShare)) / 1e12,
            isStaking: true
        });
        amountOfUsers++;
        emit Stake(msg.sender, amount);
    }

    /// @dev Transfers tokens to user with reward
    function unstake() external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.isStaking, 'User did not stake tokens');
        updatePool();
        uint256 reward = ((user.amount * pool.accTokenPerShare) / 1e12) - user.rewardDebt;
        require(pool.rewardPool >= reward, 'reserves empty');
        pool.totalStaked -= user.amount;
        pool.rewardPool -= reward;
        rewardToken.transfer(msg.sender, reward + user.amount);

        delete userInfo[msg.sender];
        amountOfUsers--;
        emit Unstake(msg.sender, reward);
    }

    /// @dev Updates reward variables of the given pool to be up-to-date.
    function updatePool() public {
        if (block.number <= pool.lastRewardBlock) return;
        if (pool.totalStaked == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        pool.accTokenPerShare +=
            (((block.number - pool.lastRewardBlock) * pool.rate * 1e12 * 1e18) / 1000) /
            pool.totalStaked;
        pool.lastRewardBlock = block.number;
    }

    /// @dev Receives reward token and increasing reward pool of selected pool
    /// @param period period to airdrop all reward pool
    /// @param amount amount of reward tokens to increase the pool
    function increaseRewardPool(uint256 period, uint256 amount) external onlyOwner {
        rewardToken.transferFrom(msg.sender, address(this), amount);
        require(period != 0, 'zero period');
        /* if reward pool and period did not pass
       and owner wants to add liquidity,
       than calculates ramaning current reward pool
       and adding it to reward pool owner wants to add
       */
        if (pool.rewardPool > 0) {
            if (block.timestamp <= (pool.period + pool.timePoolAdded)) {
                amount +=
                    pool.rewardPool -
                    (pool.rewardPool * (block.timestamp - pool.timePoolAdded)) /
                    pool.period;
            }
        }
        pool.rewardPool += amount;
        pool.timePoolAdded = block.timestamp;
        pool.period = period;
        _set(period, amount);
    }

    /// @dev Changes rates of selected pool
    /// @param period period to airdrop all reward pool
    /// @param rewardPool amount of reward pool
    function _set(uint256 period, uint256 rewardPool) internal {
        updatePool();
        pool.rate = _calcRate(period, rewardPool);
        require(pool.rate < 1e6, 'Overflow prevention');
    }

    /// @dev Calculates lp tokens reward
    /// @param who staking user
    /// @return lp token reward amount
    function pendingReward(address who) external view returns (uint256) {
        UserInfo storage user = userInfo[who];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        if (block.number > pool.lastRewardBlock && pool.totalStaked != 0) {
            accTokenPerShare +=
                ((block.number - pool.lastRewardBlock) * pool.rate * 1e12 * 1e18) /
                1000 /
                pool.totalStaked;
        }
        return ((user.amount * accTokenPerShare) / 1e12) - user.rewardDebt;
    }

    /// @dev Creates pool
    function _initPool() internal {
        pool = PoolInfo({
            rate: 0,
            lastRewardBlock: block.number,
            accTokenPerShare: 0,
            totalStaked: 0,
            rewardPool: 0,
            timePoolAdded: 0,
            period: 0
        });
    }

    /// @dev Calculates token reward per block based on reward pool and airdrop period
    /// @param period duraion of token rewards per block
    /// @param rewardPool reward token to be airdroped during period
    /// @return token per block nomerator, where denominator is always 1000
    function _calcRate(uint256 period, uint256 rewardPool)
        internal
        pure
        returns (uint256)
    {
        require(rewardPool >= 1000 * 10**18, 'to low reward pool amount'); // preventing zero rates
        return (rewardPool * 1000) / (period / 3) / 10**18;
    }
}