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

pragma solidity ^0.8.0;

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IRewarder.sol";
import "./libraries/TransferHelper.sol";

contract SBMasterChef is Ownable, ReentrancyGuard {
    /// `amount` LP token amount the user has provided.
    /// `rewardDebt` The amount of SB entitled to the user.
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingRewards;
    }

    /// `allocPoint` The amount of allocation points assigned to the pool.
    /// Also known as the amount of SB to distribute per block.
    struct PoolInfo {
        uint128 accSBPerShare;
        uint128 allocPoint;
        uint256 lastRewardBlock;
        address lpToken;
    }

    PoolInfo[] public poolInfo;
    IRewarder public rewarder;

    /// @notice Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo; // poolId => user_address => userInfo
    mapping(address => bool) private poolExistence; // lp address => bool

    /// @dev Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    uint256 private constant ACC_SB_PRECISION = 1e12;

    uint256 public sbPerBlock;
    uint256 public immutable rewardStartTimestamp;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Withdraw(address indexed to, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 indexed pid, uint256 pending, uint256 harvested);
    event LogPoolAddition(uint256 indexed pid, uint256 allocPoint, address indexed lpToken);
    event LogSetPool(uint256 indexed pid, uint256 allocPoint);
    event LogUpdatePool(uint256 indexed pid, uint256 lastRewardBlock, uint256 lpSupply, uint256 accSBPerShare);
    event LogInit();
    event LogSetRewarder(address indexed _user, address indexed _rewarder);
    event LogSetSBPerBlock(address indexed user, uint256 amount);

    constructor(uint256 _sbPerBlock, uint256 _rewardTimestamp) {
        require(_rewardTimestamp >= block.timestamp, "SBMasterChef: Invalid reward start timestamp");
        sbPerBlock = _sbPerBlock;
        rewardStartTimestamp = _rewardTimestamp;
    }

    function poolLength() external view returns (uint256 pools) {
        pools = poolInfo.length;
    }

    function setRewarder(IRewarder _rewarder) external onlyOwner {
        require(address(_rewarder) != address(0), "SBMasterChef: ZERO address");
        rewarder = _rewarder;

        emit LogSetRewarder(msg.sender, address(_rewarder));
    }

    function setSBPerBlock(uint256 _sbPerBlock) external onlyOwner {
        sbPerBlock = _sbPerBlock;
        emit LogSetSBPerBlock(msg.sender, _sbPerBlock);
    }

    /// @notice Add a new LP to the pool. Can only be called by the owner.
    /// DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    /// @param allocPoint AP of the new pool. 100 - 1 point
    /// @param _lpToken Address of the LP ERC-20 token.
    function add(uint256 allocPoint, address _lpToken) external onlyOwner nonReentrant {
        require(!poolExistence[_lpToken], "SBMasterChef: Pool already exists");
        require(_lpToken != address(0), "SBMasterChef: ZERO address");

        totalAllocPoint = totalAllocPoint + allocPoint;
        poolExistence[_lpToken] = true;

        poolInfo.push(
            PoolInfo({
                accSBPerShare: 0,
                allocPoint: uint128(allocPoint),
                lastRewardBlock: block.number,
                lpToken: _lpToken
            })
        );
        emit LogPoolAddition(poolInfo.length - 1, allocPoint, _lpToken);
    }

    /// @notice Update the given pool's SB allocation point and `IRewarder` contract.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _allocPoint New AP of the pool.
    function set(uint256 _pid, uint256 _allocPoint) external onlyOwner {
        require(_pid < poolInfo.length, "SBMasterChef: Pool does not exist");
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = uint128(_allocPoint);
        emit LogSetPool(_pid, _allocPoint);
    }

    /// @notice View function to see pending SB on frontend.
    /// @param _pid The index of the pool. See `poolInfo`.
    /// @param _user Address of user.
    /// @return pending SB reward for a given user.
    function pendingRewards(uint256 _pid, address _user) external view returns (uint256 pending) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];

        uint256 accSBPerShare = pool.accSBPerShare;
        uint256 lpSupply = IERC20(pool.lpToken).balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blocks = block.number - pool.lastRewardBlock;
            uint256 sbReward = (blocks * sbPerBlock * pool.allocPoint) / totalAllocPoint;
            accSBPerShare = accSBPerShare + ((sbReward * ACC_SB_PRECISION) / lpSupply);
        }
        pending = user.pendingRewards + (user.amount * accSBPerShare) / ACC_SB_PRECISION - uint256(user.rewardDebt);
    }

    /// @notice Update reward variables for pool.
    /// @param pid Pool ID to be updated.
    function updatePool(uint256 pid) external nonReentrant {
        _updatePool(pid);
    }

    /// @notice Update reward variables of the given pool.
    /// @param pid The index of the pool. See `poolInfo`.
    function _updatePool(uint256 pid) private {
        PoolInfo storage pool = poolInfo[pid];
        if (block.number > pool.lastRewardBlock) {
            uint256 lpSupply = IERC20(pool.lpToken).balanceOf(address(this));
            if (lpSupply > 0) {
                uint256 blocks = block.number - pool.lastRewardBlock;
                uint256 sbReward = (blocks * sbPerBlock * pool.allocPoint) / totalAllocPoint;
                pool.accSBPerShare = pool.accSBPerShare + uint128((sbReward * ACC_SB_PRECISION) / lpSupply);
            }
            pool.lastRewardBlock = block.number;
            emit LogUpdatePool(pid, pool.lastRewardBlock, lpSupply, pool.accSBPerShare);
        }
    }

    /// @param pid The index of the pool. See `poolInfo`.
    /// @param amount LP token amount to deposit. If amount = 0, it means user wants to harvest
    /// @param to The receiver of `amount` deposit benefit.
    function deposit(
        uint256 pid,
        uint256 amount,
        address to
    ) external nonReentrant {
        require(pid < poolInfo.length, "SBMasterChef: Pool does not exist");
        require(block.timestamp > rewardStartTimestamp, "SBMasterChef: Deposit is not started yet");
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][to];
        _updatePool(pid);

        // harvest current reward
        if (user.amount > 0) {
            harvest(pid, to);
        }

        if (amount > 0) {
            TransferHelper.safeTransferFrom(pool.lpToken, msg.sender, address(this), amount);
            user.amount = user.amount + amount;
        }

        user.rewardDebt = (user.amount * pool.accSBPerShare) / ACC_SB_PRECISION;
        emit Deposit(msg.sender, pid, amount, to);
    }

    /// @param pid The index of the pool. See `poolInfo`.
    /// @param amount LP token amount to withdraw.
    function withdraw(uint256 pid, uint256 amount) external nonReentrant {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        _updatePool(pid);
        harvest(pid, msg.sender);

        if (amount > 0) {
            user.amount = user.amount - amount;
            TransferHelper.safeTransfer(pool.lpToken, msg.sender, amount);
        }
        user.rewardDebt = (user.amount * pool.accSBPerShare) / ACC_SB_PRECISION;

        emit Withdraw(msg.sender, pid, amount);
    }

    /// @notice Harvest proceeds for transaction sender to `to`.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @param to Receiver of SB rewards.
    function harvest(uint256 pid, address to) private {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][to];

        // harvest current reward
        uint256 pending = user.pendingRewards + (user.amount * pool.accSBPerShare) / ACC_SB_PRECISION - user.rewardDebt;
        user.pendingRewards = pending;

        uint256 harvested;
        if (pending > 0) {
            harvested = IRewarder(rewarder).onSBReward(to, pending);
            // We assume harvested amount is less than pendingRewards
            user.pendingRewards -= harvested;
        }

        emit Harvest(to, pid, pending, harvested);
    }

    /// @notice Withdraw without caring about rewards. EMERGENCY ONLY.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @param to Receiver of the LP tokens.
    function emergencyWithdraw(uint256 pid, address to) external nonReentrant {
        UserInfo storage user = userInfo[pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        // Note: transfer can fail or succeed if `amount` is zero.
        TransferHelper.safeTransfer(poolInfo[pid].lpToken, to, amount);
        emit EmergencyWithdraw(msg.sender, pid, amount, to);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IRewarder {
    function onSBReward(address to, uint256 amount) external returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.4;

// helper methods for interacting with ERC20 tokens
library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }
}