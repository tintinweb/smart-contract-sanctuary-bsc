// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12 <0.9.0;

import "./ReentrancyGuard.sol";
import "./Ownable.sol";
import "./SafeBEP20.sol";
import "./BEP20.sol";
import "./IPancakePair.sol";

/// @title Farming contract for minted Narfex Token
/// @author Danil Sakhinov
/// @notice Distributes a reward from the balance instead of minting it
contract MasterChef is Ownable, ReentrancyGuard {
    using SafeBEP20 for IBEP20;

    // User share of a pool
    struct UserPool {
        uint256 amount; // Amount of LP tokens
        uint startBlockIndex; // Block index when farming started
        uint lastHarvestBlock; // Block number of last harvest
        uint storedReward; // Harvested reward delayed until the transaction is unlocked
        uint depositTimestamp; // Timestamp of deposit
        uint harvestTimestamp; // Timestamp of last harvest
    }

    struct Pool {
        IBEP20 token; // LP token
        mapping (address => UserPool) users; // Holder share info
        uint[] blocks; // Blocks during which the size of the pool has changed
        mapping (uint => uint) sizes; // Pool sizes during each block
        uint rewardPerBlock; // Reward for each block in this pool
        bool isExists; // Is pool allowed by owner
    }

    // Reward to harvest
    IBEP20 public rewardToken;
    // Default reward size for new pools
    uint public defaultRewardPerBlock = 1 * 10**18; // 1 wei
    // The interval from the deposit in which the commission for the reward will be taken.
    uint public commissionInterval = 14 days;
    // Interval since last harvest when next harvest is not possible
    uint public harvestInterval = 8 hours;
    // Commission for to early harvests in % (50 is 50%) based on commissionInterval
    uint public earlyHarvestCommission = 10;
    // Whether to cancel the reward for early withdrawal
    bool public isUnrewardEarlyWithdrawals = false;
    // Interval after deposit in which all rewards will be canceled
    uint public rewardCancelInterval = 14 days;
    // Referral percent for reward
    uint public referralPercent = 5;

    // Pools data
    mapping (address => Pool) public pools;
    // Pools list by addresses
    address[] public poolsList;
    // Pools count
    uint public poolsCount;
    // Address of the agents who invited the users (refer => agent)
    mapping (address => address) refers;

    event CreatePool(address indexed pair, uint rewardPerBlock, uint poolIndex);
    event Deposit(address indexed caller, address indexed pair, uint amount, uint indexed block, uint poolSize);
    event Withdraw(address indexed caller, address indexed pair, uint amount, uint indexed block, uint poolSize);
    event Harvest(address indexed caller, address indexed pair, uint indexed block, uint reward, uint commission);
    event ClearReward(address indexed caller, address indexed pair, uint indexed block);

    /// @notice All uint values can be set to 0 to use the default values
    constructor(
        address narfexTokenAddress,
        uint _rewardPerBlock,
        uint _commissionInterval,
        uint _harvestInterval,
        uint _earlyHarvestCommission,
        bool _isUnrewardEarlyWithdrawals,
        uint _rewardCancelInterval,
        uint _referralPercent
    ) {
        rewardToken = IBEP20(narfexTokenAddress);
        if (_rewardPerBlock > 0) defaultRewardPerBlock = _rewardPerBlock;
        if (_commissionInterval > 0) commissionInterval = _commissionInterval;
        if (_harvestInterval > 0) harvestInterval = _harvestInterval;
        if (_earlyHarvestCommission > 0) earlyHarvestCommission = _earlyHarvestCommission;
        isUnrewardEarlyWithdrawals = _isUnrewardEarlyWithdrawals;
        if (_rewardCancelInterval > 0) rewardCancelInterval = _rewardCancelInterval;
        if (_referralPercent > 0) referralPercent = _referralPercent;
    }

    /// @notice Returns the soil fertility
    /// @return Reward left in the common pool
    function getNarfexLeft() public view returns (uint) {
        return rewardToken.balanceOf(address(this));
    }

    /// @notice Withdraw amount of reward token to the owner
    /// @param _amount Amount of reward tokens. Can be set to 0 to withdraw all reward tokens
    function withdrawNarfex(uint _amount) public onlyOwner {
        uint amount = _amount > 0
            ? _amount
            : getNarfexLeft();
        rewardToken.transfer(address(msg.sender), amount);
    }

    /// @notice Creates a liquidity pool in the farm
    /// @param pair The address of LP token
    /// @param _rewardPerBlock Reward for each block. Set to 0 to use the default value
    /// @return The pool index in the list
    function createPool(address pair, uint _rewardPerBlock) public onlyOwner returns (uint) {
        uint rewardPerBlock = _rewardPerBlock;
        if (_rewardPerBlock == 0) {
            rewardPerBlock = defaultRewardPerBlock;
        }
        uint[] memory blocks;
        Pool storage newPool = pools[pair];
        newPool.token = IBEP20(pair);
        newPool.blocks = blocks;
        newPool.rewardPerBlock = rewardPerBlock;
        newPool.isExists = true;
        poolsList.push(pair);
        poolsCount = poolsList.length;
        uint poolIndex = poolsCount - 1;
        emit CreatePool(pair, rewardPerBlock, poolIndex);
        return poolIndex;
    }

    /// @notice Deposit LP tokens to the farm. It will try to harvest first
    /// @param pair The address of LP token
    /// @param amount Amount of LP tokens to deposit
    /// @param referAgent Address of the agent who invited the user
    function deposit(address pair, uint amount, address referAgent) public nonReentrant {
        Pool storage pool = pools[pair];
        require(amount > 0, "Amount must be above zero");
        require(pool.isExists, "Pool is not exists");
        require(pool.token.balanceOf(address(msg.sender)) >= amount, "Not enough LP balance");

        // Set user agent
        if (address(referAgent) != address(0)) {
            setUserReferAgent(referAgent);
        }

        // Try to harvest before deposit
        harvest(pair);
        // TODO: Do I need to make pool.token.approve there is with web3 calls?
        // Main transfer operation
        pool.token.safeTransferFrom(address(msg.sender), address(this), amount);

        uint blockIndex = 0;
        if (pool.blocks.length == 0) {
            // It it's the first deposit, just add the block
            pool.sizes[block.number] = amount;
            // Add block to known blocks
            pool.blocks.push(block.number);
        } else {
            // Update last pool size
            pool.sizes[block.number] = getPoolSize(pair) + amount;
            // Add block to known blocks
            if (_getPoolLastBlock(pair) != block.number) {
                pool.blocks.push(block.number);
            }
            blockIndex = pool.blocks.length - 1;
        }

        // Update user start harvest block
        UserPool storage user = pool.users[address(msg.sender)];
        user.amount = user.amount == 0 ? amount : user.amount + amount;
        user.startBlockIndex = blockIndex;
        user.depositTimestamp = block.timestamp;
        user.harvestTimestamp = block.timestamp;

        emit Deposit(address(msg.sender), pair, amount, block.number, pool.sizes[block.number]);
    }

    /// @notice Withdraw LP tokens from the farm. It will try to harvest first
    /// @param pair The address of LP token
    /// @param amount Amount of LP tokens to withdraw
    function withdraw(address pair, uint amount) public nonReentrant {
        Pool storage pool = pools[pair];
        UserPool storage user = pool.users[address(msg.sender)];
        require(amount > 0, "Amount must be above zero");
        require(pool.isExists, "Pool is not exists");
        require(getUserPoolSize(pair, address(msg.sender)) >= amount, "Not enough LP balance");

        if (isUnrewardEarlyWithdrawals && user.depositTimestamp + rewardCancelInterval < block.timestamp) {
            // Clear user reward for early withdraw if this feature is turned on
            _clearUserReward(pair, address(msg.sender));
        } else {
            // Try to harvest before withdraw
            harvest(pair);
        }
        // Main transfer operation
        pool.token.safeTransfer(address(msg.sender), amount);

        // Update pool size
        pool.sizes[block.number] = getPoolSize(pair) - amount;
        // Update last changes block
        if (block.number != _getPoolLastBlock(pair)) {
            pool.blocks.push(block.number);
        }

        // Update user pool
        user.amount = user.amount - amount;
        user.startBlockIndex = pool.blocks.length;
        user.harvestTimestamp = block.timestamp;

        emit Withdraw(address(msg.sender), pair, amount, block.number, pool.sizes[block.number]);
    }

    /// @notice Returns the last block number in which the pool size was changed
    /// @param pair The address of LP token
    /// @return block number
    function _getPoolLastBlock(address pair) internal view returns (uint) {
        Pool storage pool = pools[pair];
        return pool.blocks[pool.blocks.length - 1];
    }

    /// @notice Returns the pool size after the last pool changes
    /// @param pair The address of LP token
    /// @return pool size
    function getPoolSize(address pair) public view returns (uint) {
        if (pools[pair].isExists && pools[pair].blocks.length > 0) {
            return pools[pair].sizes[_getPoolLastBlock(pair)];
        } else {
            return 0;
        }
    }

    /// @notice Returns user's amount of LP tokens
    /// @param pair The address of LP token
    /// @param userAddress The user address
    /// @return user's pool size
    function getUserPoolSize(address pair, address userAddress) public view returns (uint) {
        Pool storage pool = pools[pair];
        if (pool.isExists && pool.blocks.length > 0) {
            return pool.users[userAddress].amount;
        } else {
            return 0;
        }
    }

    /// @notice The number of the last block during which the harvest took place
    /// @param pair The address of LP token
    /// @param userAddress The user address
    /// @return block number
    function getUserLastHarvestBlock(address pair, address userAddress) public view returns (uint) {
        return pools[pair].users[userAddress].lastHarvestBlock;
    }

    /// @notice Returns wei number in 2-decimals (as %) for better console logging
    /// @param value Number in wei
    /// @return value in percents
    function getHundreds(uint value) internal pure returns (uint) {
        return value * 100 / 10**18;
    }

    /// @notice Calculates the user's reward based on a blocks range
    /// @notice Taking into account the changing size of the pool during this time
    /// @param pair The address of LP token
    /// @param userAddress The user address
    /// @return reward size
    function getUserReward(address pair, address userAddress) public view returns (uint) {
        Pool storage pool = pools[pair];
        UserPool storage user = pool.users[userAddress];

        uint reward = user.storedReward;
        uint userPoolSize = getUserPoolSize(pair, userAddress);
        if (userPoolSize == 0) return 0;

        uint decimals = pool.token.decimals();

        for (uint i = user.startBlockIndex; i < pool.blocks.length; i++) {
            // End of the pool size period
            uint endBlock = i + 1 < pool.blocks.length
                ? pool.blocks[i + 1] // Next block in the array
                : block.number; // Current block number
            if (user.lastHarvestBlock + 1 > endBlock) continue;

            // Blocks range between pool size key points
            uint range = user.lastHarvestBlock + 1 > pool.blocks[i]
                ? endBlock - user.lastHarvestBlock + 1 // Last harvest could happen inside the range
                : endBlock - pool.blocks[i]; // Use startBlock as the start of the range

            // Pool size can't be empty on the range, because we use harvest before each withdraw
            require (pool.sizes[pool.blocks[i]] > 0, "[getUserReward] Bug: unexpected empty pool on some blocks range");

            // User share in this range in %
            uint share = userPoolSize * 10**decimals / pool.sizes[pool.blocks[i]];
            // Reward from this range
            uint rangeReward = share * pool.rewardPerBlock * range / 10**decimals;
            // Add reward to total
            reward += rangeReward;
        }

        return reward;
    }

    /// @notice If enough time has passed since the last harvest
    /// @param pair The address of LP token
    /// @param userAddress The user address
    /// @return true if user can harvest
    function getIsUserCanHarvest(address pair, address userAddress) public view returns (bool) {
        UserPool storage user = pools[pair].users[userAddress];
        return isUnrewardEarlyWithdrawals
            // Is reward clearing feature is turned on
            ? user.depositTimestamp + rewardCancelInterval < block.timestamp
                && user.harvestTimestamp + harvestInterval < block.timestamp
            // Use only harvest interval
            : user.harvestTimestamp + harvestInterval < block.timestamp;
    }

    /// @notice Whether to charge the user an early withdrawal fee
    /// @param pair The address of LP token
    /// @param userAddress The user address
    /// @return true if it's to early to withdraw
    function getIsEarlyHarvest(address pair, address userAddress) public view returns (bool) {
        return pools[pair].users[userAddress].depositTimestamp + commissionInterval > block.timestamp;
    }

    /// @notice Try to harvest reward from the pool.
    /// @notice Will send a reward to the user if enough time has passed since the last harvest
    /// @param pair The address of LP token
    /// @return transferred reward amount
    function harvest(address pair) public returns (uint) {
        UserPool storage user = pools[pair].users[address(msg.sender)];

        uint reward = getUserReward(pair, address(msg.sender));
        if (reward == 0) return 0;

        if (getIsUserCanHarvest(pair, address(msg.sender))) {
            // Calculate commission for early withdraw
            uint commission = getIsEarlyHarvest(pair, address(msg.sender))
                ? reward * earlyHarvestCommission / 100
                : 0;
            if (commission > 0) {
                reward -= commission;
            }

            // User can harvest only after harvest inverval
            rewardToken.safeTransfer(address(msg.sender), reward);
            emit Harvest(address(msg.sender), pair, block.number, reward, commission);

            user.harvestTimestamp = block.timestamp;
            user.lastHarvestBlock = block.number;

            // Send a referral reward to the agent
            address agent = refers[address(msg.sender)];
            if (address(agent) != address(0)) {
                rewardToken.safeTransfer(agent, getReferralReward(reward)); 
            }

            return reward;
        } else {
            // Store the reward and update the last harvest block
            user.storedReward = reward;
            user.lastHarvestBlock = block.number;
            return 0;
        }
    }

    /// @notice Clears user's reward in the pool
    /// @param pair The address of LP token
    /// @param userAddress The user address
    function _clearUserReward(address pair, address userAddress) internal {
        UserPool storage user = pools[pair].users[userAddress];
        user.storedReward = 0;
        user.harvestTimestamp = block.timestamp;
        user.lastHarvestBlock = _getPoolLastBlock(pair);
        user.startBlockIndex = pools[pair].blocks[pools[pair].blocks.length - 1];
        emit ClearReward(address(msg.sender), pair, block.number);
    }
    
    /// @notice Sets the commission interval
    /// @param interval Interval size in seconds
    function setCommissionInterval(uint interval) public onlyOwner {
        commissionInterval = interval;
    }

    /// @notice Sets the harvest interval
    /// @param interval Interval size in seconds
    function setHarvestInterval(uint interval) public onlyOwner {
        harvestInterval = interval;
    }

    /// @notice Sets the harvest interval
    /// @param percents Commission in percents (10 for default 10%)
    function setEarlyHarvesCommission(uint percents) public onlyOwner {
        earlyHarvestCommission = percents;
    }

    /// @notice Toggles the feature clearing reward for early withdrawal
    function toggleRewardClearingForEarlyWithdrawals() public onlyOwner {
        isUnrewardEarlyWithdrawals = !isUnrewardEarlyWithdrawals;
    }

    /// @notice Sets the reward cancel interval
    /// @param interval Interval size in seconds
    function setRewardCancelInterval(uint interval) public onlyOwner {
        rewardCancelInterval = interval;
    }

    /// @notice Sets the default reward per block for a new pools
    /// @param reward Reward per block
    function setDefaultRewardPerBlock(uint reward) public onlyOwner {
        defaultRewardPerBlock = reward;
    }

    /// @notice Sets the reward per block value for all pools and default value
    /// @param reward Reward per block
    function updateAllPoolsRewardsSizes(uint reward) public onlyOwner {
        setDefaultRewardPerBlock(reward);
        for (uint i = 0; i < poolsList.length; i++) {
            pools[poolsList[i]].rewardPerBlock = reward;
        }
    }

    /// @notice Returns poolsList array length
    function getPoolsCount() public view returns (uint) {
        return poolsList.length;
    }

    /// @notice Returns contract settings by one request
    /// @return uintDefaultRewardPerBlock
    /// @return uintCommissionInterval
    /// @return uintHarvestInterval
    /// @return uintEarlyHarvestCommission
    /// @return boolIsUnrewardEarlyWithdrawals
    /// @return uintRewardCancelInterval
    /// @return uintReferralPercent
    function getSettings() public view returns (
        uint uintDefaultRewardPerBlock,
        uint uintCommissionInterval,
        uint uintHarvestInterval,
        uint uintEarlyHarvestCommission,
        bool boolIsUnrewardEarlyWithdrawals,
        uint uintRewardCancelInterval,
        uint uintReferralPercent
        ) {
        return (
        defaultRewardPerBlock,
        commissionInterval,
        harvestInterval,
        earlyHarvestCommission,
        isUnrewardEarlyWithdrawals,
        rewardCancelInterval,
        referralPercent
        );
    }

    /// @notice Sets the user's agent
    /// @param agent Address of the agent who invited the user
    /// @return False if the agent and the user have the same address
    function setUserReferAgent(address agent) public returns (bool) {
        if (address(msg.sender) != agent) {
            refers[address(msg.sender)] = agent;
            return true;
        } else {
            return false;
        }
    }

    /// @notice Owner can set the referral percent
    /// @param percent Referral percent
    function setReferralPercent(uint percent) public onlyOwner {
        referralPercent = percent;
    }

    /// @notice Returns agent's reward amount for referral's reward
    /// @param reward Referral's reward amount
    /// @return Agent's reward amount
    function getReferralReward(uint reward) internal view returns (uint) {
        return reward * referralPercent / 100;
    }

    /// @notice Sets a pool reward
    /// @param pair The address of LP token
    /// @param reward Amount of reward per block
    function setPoolRewardPerBlock(address pair, uint reward) public onlyOwner {
        pools[pair].rewardPerBlock = reward;
    }

    /// @notice Returns reward per block for selected pair
    /// @param pair The address of LP token
    /// @return Reward per block
    function getPoolRewardPerBlock(address pair) public view returns (uint) {
        return pools[pair].rewardPerBlock;
    }

    /// @notice Returns pool data in one request
    /// @param pair The address of LP token
    /// @return token0 First token address
    /// @return token1 Second token address
    /// @return token0symbol First token symbol
    /// @return token1symbol Second token symbol
    /// @return size Liquidity pool size
    /// @return rewardPerBlock Amount of reward token per block
    function getPoolData(address pair) public view returns (
        address token0,
        address token1,
        string memory token0symbol,
        string memory token1symbol,
        uint size,
        uint rewardPerBlock
    ) {
        Pool storage pool = pools[pair];
        IPancakePair pairToken = IPancakePair(pair);
        BEP20 _token0 = BEP20(pairToken.token0());
        BEP20 _token1 = BEP20(pairToken.token1());

        return (
            pairToken.token0(),
            pairToken.token1(),
            _token0.symbol(),
            _token1.symbol(),
            getPoolSize(pair),
            pool.rewardPerBlock
        );
    }

    /// @notice Returns pool data in one request
    /// @param pair The address of LP token
    /// @param userAddress The user address
    /// @return balance User balance of LP token
    /// @return userPool User liquidity pool size in the current pool
    /// @return reward Current user reward in the current pool
    /// @return isCanHarvest Is it time to harvest the reward
    function getPoolUserData(address pair, address userAddress) public view returns (
        uint balance,
        uint userPool,
        uint reward,
        bool isCanHarvest
    ) {
        IPancakePair pairToken = IPancakePair(pair);

        return (
            pairToken.balanceOf(userAddress),
            getUserPoolSize(pair, userAddress),
            getUserReward(pair, userAddress),
            getIsUserCanHarvest(pair, userAddress)
        );
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;


import "./Context.sol";


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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;


import "./Address.sol";
import "./IBEP20.sol";

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0<0.9.0;

import "./Context.sol";
import "./IBEP20.sol";
import "./Ownable.sol";
import "./Address.sol";




/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-BEP20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of BEP20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
contract BEP20 is Context, IBEP20, Ownable {
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory tokenName, string memory tokenSymbol) {
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token name.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()] - amount
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12 <0.9.0;

interface IPancakePair {
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0 <0.9.0;

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