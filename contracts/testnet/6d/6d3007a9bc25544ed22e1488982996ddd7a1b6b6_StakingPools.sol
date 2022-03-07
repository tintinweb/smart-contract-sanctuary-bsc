// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "../interfaces/IStakingPoolRewarder.sol";
import "../interfaces/IStakingPools.sol";

/**
 * @title StakingPools
 *
 * @dev A contract for staking sniper tokens in exchange for locked DOB rewards.
 * No actual DOB tokens will be held or distributed by this contract. Only the amounts
 * are accumulated.
 *
 */
contract StakingPools is OwnableUpgradeable, IStakingPools {
    using SafeMathUpgradeable for uint256;

    event PoolCreated(
        uint256 indexed poolId,
        address indexed token,
        address indexed optionContract,
        uint256 startBlock,
        uint256 endBlock,
        uint256 rewardPerBlock
    );

    event PoolEndBlockExtended(uint256 indexed poolId, uint256 oldEndBlock, uint256 newEndBlock);
    event PoolRewardRateChanged(uint256 indexed poolId, uint256 oldRewardPerBlock, uint256 newRewardPerBlock);
    event RewarderChanged(address oldRewarder, address newRewarder);
    event Staked(uint256 indexed poolId, address indexed staker, address token, uint256 amount);
    event Unstaked(uint256 indexed poolId, address indexed staker, address token, uint256 amount);
    event RewardRedeemed(uint256 indexed poolId, address indexed staker, address rewarder, uint256 amount);
    event FactoryChanged(address oldFactory, address newFactory);

    /**
     * @param startBlock the block from which reward accumulation starts
     * @param endBlock the block from which reward accumulation stops
     * @param rewardPerBlock total amount of token to be rewarded in a block
     * @param poolToken token to be staked
     */
    struct PoolInfo {
        uint256 startBlock;
        uint256 endBlock;
        uint256 rewardPerBlock;
        address poolToken;
        address optionContract;
    }
    /**
     * @param totalStakeAmount total amount of staked tokens
     * @param accuRewardPerShare accumulated rewards for a single unit of token staked, multiplied by `ACCU_REWARD_MULTIPLIER`
     * @param accuRewardLastUpdateBlock the block number at which the `accuRewardPerShare` field was last updated
     */
    struct PoolData {
        uint256 totalStakeAmount;
        uint256 accuRewardPerShare;
        uint256 accuRewardLastUpdateBlock;
    }
    /**
     * @param stakeAmount amount of token the user stakes
     * @param pendingReward amount of reward to be redeemed by the user up to the user's last action
     * @param entryAccuRewardPerShare the `accuRewardPerShare` value at the user's last stake/unstake action
     */
    struct UserData {
        uint256 stakeAmount;
        uint256 pendingReward;
        uint256 entryAccuRewardPerShare;
        uint256 entryTime;
    }

    address public optionFactory;

    uint256 public lastPoolId; // The first pool has ID of 1

    IStakingPoolRewarder public rewarder;

    mapping(uint256 => PoolInfo) public poolInfos;
    mapping(uint256 => PoolData) public poolData;
    mapping(uint256 => mapping(address => UserData)) public userData;

    uint256 private constant ACCU_REWARD_MULTIPLIER = 10**20; // Precision loss prevention

    bytes4 private constant TRANSFER_SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));
    bytes4 private constant APPROVE_SELECTOR = bytes4(keccak256(bytes("approve(address,uint256)")));
    bytes4 private constant TRANSFERFROM_SELECTOR = bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));

    modifier onlyPoolExists(uint256 poolId) {
        require(poolInfos[poolId].endBlock > 0, "StakingPools: pool not found");
        _;
    }

    modifier onlyPoolActive(uint256 poolId) {
        require(
            block.number >= poolInfos[poolId].startBlock && block.number < poolInfos[poolId].endBlock,
            "StakingPools: pool not active"
        );
        _;
    }

    modifier onlyPoolNotEnded(uint256 poolId) {
        require(block.number < poolInfos[poolId].endBlock, "StakingPools: pool ended");
        _;
    }

    modifier onlyOptionContract(uint256 poolId) {
        require(msg.sender == poolInfos[poolId].optionContract, "StakingPools: only option contract");
        _;
    }

    modifier onlyOwnerOrFactory() {
        require(
            msg.sender == optionFactory || msg.sender == owner(),
            "StakingPools: caller is not the optionFactory or owner"
        );
        _;
    }

    function getPendingReward(uint256 poolId, address staker) external view returns (uint256) {
        UserData memory currentUserData = userData[poolId][staker];
        PoolInfo memory currentPoolInfo = poolInfos[poolId];
        PoolData memory currentPoolData = poolData[poolId];

        uint256 latestAccuRewardPerShare = currentPoolData.totalStakeAmount > 0
            ? currentPoolData.accuRewardPerShare.add(
                MathUpgradeable
                .min(block.number, currentPoolInfo.endBlock)
                .sub(currentPoolData.accuRewardLastUpdateBlock)
                .mul(currentPoolInfo.rewardPerBlock)
                .mul(ACCU_REWARD_MULTIPLIER)
                .div(currentPoolData.totalStakeAmount)
            )
            : currentPoolData.accuRewardPerShare;

        return
            currentUserData.pendingReward.add(
                currentUserData.stakeAmount.mul(latestAccuRewardPerShare.sub(currentUserData.entryAccuRewardPerShare)).div(
                    ACCU_REWARD_MULTIPLIER
                )
            );
    }

    function getStakingAmountByPoolID(address user, uint256 poolId) external view override returns (uint256) {
        return userData[poolId][user].stakeAmount;
    }

    function __StakingPools_init() public initializer {
        __Ownable_init();
    }

    function createPool(
        address token,
        address optionContract,
        uint256 startBlock,
        uint256 endBlock,
        uint256 rewardPerBlock
    ) external override onlyOwnerOrFactory {
        require(token != address(0), "StakingPools: zero address");
        require(optionContract != address(0), "StakingPools: zero address");
        require(startBlock > block.number && endBlock > startBlock, "StakingPools: invalid block range");
        require(rewardPerBlock > 0, "StakingPools: reward must be positive");

        uint256 newPoolId = ++lastPoolId;

        poolInfos[newPoolId] = PoolInfo({
            startBlock: startBlock,
            endBlock: endBlock,
            rewardPerBlock: rewardPerBlock,
            poolToken: token,
            optionContract: optionContract
        });
        poolData[newPoolId] = PoolData({totalStakeAmount: 0, accuRewardPerShare: 0, accuRewardLastUpdateBlock: startBlock});

        emit PoolCreated(newPoolId, token, optionContract, startBlock, endBlock, rewardPerBlock);
    }

    function extendEndBlock(uint256 poolId, uint256 newEndBlock)
        external
        override
        onlyOwner
        onlyPoolExists(poolId)
        onlyPoolNotEnded(poolId)
    {
        uint256 currentEndBlock = poolInfos[poolId].endBlock;
        require(newEndBlock > currentEndBlock, "StakingPools: end block not extended");

        poolInfos[poolId].endBlock = newEndBlock;

        emit PoolEndBlockExtended(poolId, currentEndBlock, newEndBlock);
    }

    function setPoolReward(uint256 poolId, uint256 newRewardPerBlock)
        external
        onlyOwner
        onlyPoolExists(poolId)
        onlyPoolNotEnded(poolId)
    {
        if (block.number >= poolInfos[poolId].startBlock) {
            // "Settle" rewards up to this block
            _updatePoolAccuReward(poolId);
        }

        // We're deliberately allowing setting the reward rate to 0 here. If it turns
        // out this, or even changing rates at all, is undesirable after deployment, the
        // ownership of this contract can be transferred to a contract incapable of making
        // calls to this function.
        uint256 currentRewardPerBlock = poolInfos[poolId].rewardPerBlock;
        poolInfos[poolId].rewardPerBlock = newRewardPerBlock;

        emit PoolRewardRateChanged(poolId, currentRewardPerBlock, newRewardPerBlock);
    }

    function setRewarder(address newRewarder) external onlyOwner {
        require(newRewarder != address(0), "StakingPools: zero address");

        address oldRewarder = address(rewarder);
        rewarder = IStakingPoolRewarder(newRewarder);

        emit RewarderChanged(oldRewarder, newRewarder);
    }

    function setFactory(address newFactory) external onlyOwner {
        require(newFactory != address(0), "StakingPools: zero address");

        address oldFactory = optionFactory;
        optionFactory = newFactory;

        emit FactoryChanged(oldFactory, optionFactory);
    }

    function stake(uint256 poolId, uint256 amount) external onlyPoolExists(poolId) onlyPoolActive(poolId) {
        _updatePoolAccuReward(poolId);
        _updateStakerReward(poolId, msg.sender);

        _stake(poolId, msg.sender, amount);
    }

    function unstake(uint256 poolId, uint256 amount) external onlyPoolExists(poolId) {
        _updatePoolAccuReward(poolId);
        _updateStakerReward(poolId, msg.sender);

        _unstake(poolId, msg.sender, amount);
    }

    function stakeFor(
        uint256 poolId,
        uint256 amount,
        address user
    ) external override onlyPoolExists(poolId) onlyPoolActive(poolId) onlyOptionContract(poolId) {
        require(user != address(0), "StakingPools: zero address");

        _updatePoolAccuReward(poolId);
        _updateStakerReward(poolId, user);

        require(amount > 0, "StakingPools: cannot stake zero amount");

        userData[poolId][user].stakeAmount = userData[poolId][user].stakeAmount.add(amount);
        poolData[poolId].totalStakeAmount = poolData[poolId].totalStakeAmount.add(amount);

        // settle pending rewards to rewarder with vesting so that entryTime can be updated
        _vestPendingRewards(poolId, user);
        userData[poolId][user].entryTime = block.timestamp;

        emit Staked(poolId, user, poolInfos[poolId].poolToken, amount);
    }

    function unstakeFor(
        uint256 poolId,
        uint256 amount,
        address user
    ) external override onlyPoolExists(poolId) onlyOptionContract(poolId) {
        require(user != address(0), "StakingPools: zero address");

        _updatePoolAccuReward(poolId);
        _updateStakerReward(poolId, user);

        require(amount > 0, "StakingPools: cannot unstake zero amount");

        // No sufficiency check required as sub() will throw anyways
        userData[poolId][user].stakeAmount = userData[poolId][user].stakeAmount.sub(amount);
        poolData[poolId].totalStakeAmount = poolData[poolId].totalStakeAmount.sub(amount);

        safeTransfer(poolInfos[poolId].poolToken, user, amount);

        emit Unstaked(poolId, user, poolInfos[poolId].poolToken, amount);
    }

    function emergencyUnstake(uint256 poolId) external onlyPoolExists(poolId) {
        _unstake(poolId, msg.sender, userData[poolId][msg.sender].stakeAmount);

        // Forfeit user rewards to avoid abuse
        userData[poolId][msg.sender].pendingReward = 0;
    }

    function redeemRewards(uint256 poolId) external {
        _redeemRewardsByAddress(poolId, msg.sender);
    }

    function redeemRewardsByAddress(uint256 poolId, address user) external {
        _redeemRewardsByAddress(poolId, user);
    }

    function unstakeAndRedeemReward(uint256 poolId, uint256 amount) external {
        _updatePoolAccuReward(poolId);
        _updateStakerReward(poolId, msg.sender);

        _unstake(poolId, msg.sender, amount);

        _redeemRewardsByAddress(poolId, msg.sender);
    }

    function _redeemRewardsByAddress(uint256 poolId, address user) private onlyPoolExists(poolId) {
        require(user != address(0), "StakingPools: zero address");

        _updatePoolAccuReward(poolId);
        _updateStakerReward(poolId, user);

        require(address(rewarder) != address(0), "StakingPools: rewarder not set");

        _vestPendingRewards(poolId, user);

        uint256 claimed = rewarder.claimVestedReward(poolId, user);

        emit RewardRedeemed(poolId, user, address(rewarder), claimed);
    }

    function _vestPendingRewards(uint256 poolId, address user) private onlyPoolExists(poolId) {
        uint256 rewardToVest = userData[poolId][user].pendingReward;
        userData[poolId][user].pendingReward = 0;
        rewarder.onReward(poolId, user, rewardToVest, userData[poolId][user].entryTime);
    }

    function _stake(
        uint256 poolId,
        address user,
        uint256 amount
    ) private {
        require(amount > 0, "StakingPools: cannot stake zero amount");

        userData[poolId][user].stakeAmount = userData[poolId][user].stakeAmount.add(amount);
        poolData[poolId].totalStakeAmount = poolData[poolId].totalStakeAmount.add(amount);

        safeTransferFrom(poolInfos[poolId].poolToken, user, address(this), amount);

        // settle pending rewards to rewarder with vesting so that entryTime can be updated
        _vestPendingRewards(poolId, user);
        userData[poolId][user].entryTime = block.timestamp;

        emit Staked(poolId, user, poolInfos[poolId].poolToken, amount);
    }

    function _unstake(
        uint256 poolId,
        address user,
        uint256 amount
    ) private {
        require(amount > 0, "StakingPools: cannot unstake zero amount");

        // No sufficiency check required as sub() will throw anyways
        userData[poolId][user].stakeAmount = userData[poolId][user].stakeAmount.sub(amount);
        poolData[poolId].totalStakeAmount = poolData[poolId].totalStakeAmount.sub(amount);

        safeTransfer(poolInfos[poolId].poolToken, user, amount);

        emit Unstaked(poolId, user, poolInfos[poolId].poolToken, amount);
    }

    function _updatePoolAccuReward(uint256 poolId) private {
        PoolInfo storage currentPoolInfo = poolInfos[poolId];
        PoolData storage currentPoolData = poolData[poolId];

        uint256 appliedUpdateBlock = MathUpgradeable.min(block.number, currentPoolInfo.endBlock);
        uint256 durationInBlocks = appliedUpdateBlock.sub(currentPoolData.accuRewardLastUpdateBlock);

        // This saves tx cost when being called multiple times in the same block
        if (durationInBlocks > 0) {
            // No need to update the rate if no one staked at all
            if (currentPoolData.totalStakeAmount > 0) {
                currentPoolData.accuRewardPerShare = currentPoolData.accuRewardPerShare.add(
                    durationInBlocks.mul(currentPoolInfo.rewardPerBlock).mul(ACCU_REWARD_MULTIPLIER).div(
                        currentPoolData.totalStakeAmount
                    )
                );
            }
            currentPoolData.accuRewardLastUpdateBlock = appliedUpdateBlock;
        }
    }

    function _updateStakerReward(uint256 poolId, address staker) private {
        UserData storage currentUserData = userData[poolId][staker];
        PoolData storage currentPoolData = poolData[poolId];

        uint256 stakeAmount = currentUserData.stakeAmount;
        uint256 stakerEntryRate = currentUserData.entryAccuRewardPerShare;
        uint256 accuDifference = currentPoolData.accuRewardPerShare.sub(stakerEntryRate);

        if (accuDifference > 0) {
            currentUserData.pendingReward = currentUserData.pendingReward.add(
                stakeAmount.mul(accuDifference).div(ACCU_REWARD_MULTIPLIER)
            );
            currentUserData.entryAccuRewardPerShare = currentPoolData.accuRewardPerShare;
        }
    }

    function safeApprove(
        address token,
        address spender,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(APPROVE_SELECTOR, spender, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "StakingPools: approve failed");
    }

    function safeTransfer(
        address token,
        address recipient,
        uint256 amount
    ) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(TRANSFER_SELECTOR, recipient, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "StakingPools: transfer failed");
    }

    function safeTransferFrom(
        address token,
        address sender,
        address recipient,
        uint256 amount
    ) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(TRANSFERFROM_SELECTOR, sender, recipient, amount)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "StakingPools: transferFrom failed");
    }
}

// SPDX-License-Identifier: MIT

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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library MathUpgradeable {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IStakingPoolRewarder {
    function calculateTotalReward(address user, uint256 poolId) external view returns (uint256);

    function calculateWithdrawableReward(address user, uint256 poolId) external view returns (uint256);

    function onReward(
        uint256 poolId,
        address user,
        uint256 amount,
        uint256 entryTime
    ) external;

    function claimVestedReward(uint256 poolId, address user) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IStakingPools {
    function createPool(
        address token,
        address optionContract,
        uint256 startBlock,
        uint256 endBlock,
        uint256 rewardPerBlock
    ) external;

    function extendEndBlock(uint256 poolId, uint256 newEndBlock) external;

    function getStakingAmountByPoolID(address user, uint256 poolId) external returns (uint256);

    function stakeFor(
        uint256 poolId,
        uint256 amount,
        address user
    ) external;

    function unstakeFor(
        uint256 poolId,
        uint256 amount,
        address user
    ) external;
}

// SPDX-License-Identifier: MIT

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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}