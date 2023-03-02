// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../lib/IBEP20.sol";
import "../lib/SafeBEP20.sol";
import "../lib/IRewarder.sol";
import "../lib/ITBCCMasterChef.sol";
import "../lib/ITFT.sol";
import '../lib/ITBCCDEFIAPES.sol';

interface IMigratorChef {
    function migrate(IBEP20 token) external returns (IBEP20);
}

contract TBCCMasterChef is ITBCCMasterChef, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    /// @notice Address of TFT contract.
    ITFT public tft;
    /// @notice Address of TDA contract.
    ITBCCDEFIAPES public tbccDefiApes;
    bool public claimingPause;
    // TFT tokens created per block.
    uint256 public tftPerBlock;
    // TFT tokens claim per one TBCC TDA
    uint256 public claimAmount;

    /// @notice Info of each TBCCMCV pool.
    PoolInfo[] public poolInfo;
    /// @notice Address of the LP token for each TBCCMCV pool.
    IBEP20[] public lpToken;
    /// @notice Address of each `IRewarder` contract in TBCCMCV.
    IRewarder[] public rewarder;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigratorChef public migrator;

    /// @notice Info for new bonuses
    BonusInfo[] public bonuses;
    /// @notice Info of each pool user.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    /// @dev Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint;
    // The block number when TFT mining starts.
    uint256 public startBlock;
    /// @notice Info of TDA claimed
    mapping(uint256 => address) public tdaClaimed;

    uint256 private constant ACC_TFT_PRECISION = 1e12;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount, address indexed to);
    event Harvest(address indexed user, uint256 indexed pid, uint256 amount);
    event LogPoolAddition(uint256 indexed pid, uint256 allocPoint, IBEP20 indexed lpToken, IRewarder indexed rewarder);
    event LogSetPool(uint256 indexed pid, uint256 allocPoint, IRewarder indexed rewarder, bool overwrite);
    event LogUpdatePool(uint256 indexed pid, uint256 lastRewardBlock, uint256 lpSupply, uint256 accTFTPerShare);
    event AddNewBonus(uint256 startBlock, uint256 bonus);
    event NFTTDAClaimed(address sender, uint256 tokenId, uint256 amount);
    event NewClaimApesAmount(uint256 newAmount);

    // Modifier for NFT holder
    modifier onlyNFTTDAHolder(address sender, uint256 tokenId) {
        require(sender == tbccDefiApes.ownerOf(tokenId), 'Only TBCC DEFI APES NFT holder');
        _;
    }

    /// @param _tft The TFT token contract address.
    constructor(
        ITFT _tft,
        ITBCCDEFIAPES _tbccDefiApes,
        uint256 _tftPerBlock,
        uint256 _startBlock,
        uint256 _claimAmount
    ) public {
        tft = _tft;
        tftPerBlock = _tftPerBlock;
        startBlock = _startBlock;
        tbccDefiApes = _tbccDefiApes;
        claimAmount = _claimAmount;
        bonuses.push(BonusInfo(_startBlock, 100));
    }

    /**
     * @notice Returns the number of TBCCMCV pools.
     *
     */
    function poolLength() external view returns (uint256 pools) {
        pools = poolInfo.length;
    }

    /**
     * @notice Add a new pool. Can only be called by the owner.
     * DO NOT add the same LP token more than once. Rewards will be messed up if you do.
     * @param _allocPoint: Number of allocation points for the new pool.
     * @param _lpToken: Address of the LP BEP-20 token.
     * @param _rewarder: Address of the rewarder delegate.
     *
     * @dev Callable by owner
     *
     */
    function add(
        uint256 _allocPoint,
        IBEP20 _lpToken,
        IRewarder _rewarder
    ) external onlyOwner {
        require(_lpToken.balanceOf(address(this)) >= 0, "None BEP20 tokens");
        // stake TFT token will cause staked token and reward token mixed up,
        // may cause staked tokens withdraw as reward token,never do it.
        require(address(_lpToken) != address(tft), "TFT token can't be added to farm pools");

        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        lpToken.push(_lpToken);
        rewarder.push(_rewarder);

        poolInfo.push(
            PoolInfo({
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accTFTPerShare: 0
            })
        );
        emit LogPoolAddition(lpToken.length.sub(1), _allocPoint, _lpToken, _rewarder);
    }

    /**
     * @notice Update the given pool's TFT allocation point. Can only be called by the owner.
     * @param _pid: The id of the pool. See `poolInfo`.
     * @param _allocPoint: New number of allocation points for the pool.
     * @param _rewarder: Address of the rewarder delegate.
     * @param _overwrite: True if _rewarder should be `set`. Otherwise `_rewarder` is ignored.
     *
     * @dev Callable by owner
     *
     */
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        IRewarder _rewarder,
        bool _overwrite
    ) external onlyOwner {
        require(_pid < lpToken.length, "TBCCMasterChef: pid is not found");

        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;

        if (_overwrite) {
            rewarder[_pid] = _rewarder;
        }

        emit LogSetPool(_pid, _allocPoint, _overwrite ? _rewarder : rewarder[_pid], _overwrite);
    }

    /**
     * @notice Set the `migrator` contract. Can only be called by the owner.
     * @param _migrator: The contract address to set.
     *
     */
    function setMigrator(
        IMigratorChef _migrator
    ) external onlyOwner {
        migrator = _migrator;
    }

    /**
     * @notice Migrate LP token to another LP contract through the `migrator` contract.
     * @param _pid: The index of the pool. See `poolInfo`.
     *
     */
    function migrate(
        uint256 _pid
    ) external {
        require(address(migrator) != address(0), "TBCCMasterChef: no migrator set");
        require(_pid < lpToken.length, "TBCCMasterChef: pid is not found");

        IBEP20 _lpToken = lpToken[_pid];
        uint256 bal = _lpToken.balanceOf(address(this));
        _lpToken.approve(address(migrator), bal);

        IBEP20 newLpToken = migrator.migrate(_lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "TBCCMasterChef: migrated balance must match");
        lpToken[_pid] = newLpToken;
    }

    /**
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: Start block
     * @param _to: End Block
     *
     */
    function getMultiplier(
        uint256 _from,
        uint256 _to
    ) public view returns (uint256) {
        uint256 totalBonus;

        for (uint i; i < bonuses.length; i++) {
            uint256 stageBonus;
            if (i == bonuses.length - 1) {
                if (_from >= bonuses[i].startBlock && _to >= bonuses[i].startBlock) {
                    stageBonus = _to.sub(_from).mul(bonuses[i].bonus).div(100);
                } else if (_from < bonuses[i].startBlock && _to >= bonuses[i].startBlock) {
                    stageBonus = _to.sub(bonuses[i].startBlock).mul(bonuses[i].bonus).div(100);
                } else {
                    stageBonus = 0;
                }
            } else {
                if (_from < bonuses[i].startBlock) {
                    if (_to < bonuses[i].startBlock) {
                        stageBonus = 0;
                    } else if (_to < bonuses[i + 1].startBlock) {
                        stageBonus = _to.sub(bonuses[i].startBlock).mul(bonuses[i].bonus).div(100);
                    } else {
                        stageBonus = bonuses[i + 1].startBlock.sub(bonuses[i].startBlock).mul(bonuses[i].bonus).div(100);
                    }
                } else if (_from >= bonuses[i + 1].startBlock) {
                    stageBonus = 0;
                } else {
                    if (_to < bonuses[i].startBlock) {
                        stageBonus = 0;
                    } else if (_to < bonuses[i + 1].startBlock) {
                        stageBonus = _to.sub(_from).mul(bonuses[i].bonus).div(100);
                    } else {
                        stageBonus = bonuses[i + 1].startBlock.sub(_from).mul(bonuses[i].bonus).div(100);
                    }
                }
            }

            totalBonus = totalBonus.add(stageBonus);
        }

        return totalBonus;
    }

    /**
     * @notice View function for checking pending TFT rewards.
     * @param _pid: The id of the pool. See `poolInfo`.
     * @param _user: Address of the user.
     *
     */
    function pendingReward(
        uint256 _pid,
        address _user
    ) external view returns (uint256 pending) {
        require(_pid < lpToken.length, "TBCCMasterChef: pid is not found");

        PoolInfo memory pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTFTPerShare = pool.accTFTPerShare;
        uint256 lpSupply = lpToken[_pid].balanceOf(address(this));

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);

            uint256 tftReward = multiplier.mul(tftPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accTFTPerShare = accTFTPerShare.add(tftReward.mul(ACC_TFT_PRECISION).div(lpSupply));
        }

        pending = user.amount.mul(accTFTPerShare).div(ACC_TFT_PRECISION).sub(user.rewardDebt);
    }

    /**
     * @notice Update reward variables for the given pool.
     * @param _pid: The id of the pool. See `poolInfo`.
     *
     */
    function updatePool(
        uint256 _pid
    ) public returns (PoolInfo memory pool) {
        require(_pid < lpToken.length, "TBCCMasterChef: pid is not found");

        pool = poolInfo[_pid];

        if (block.number > pool.lastRewardBlock) {
            uint256 lpSupply = lpToken[_pid].balanceOf(address(this));
            if (lpSupply > 0) {
                uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
                uint256 tftReward = multiplier.mul(tftPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
                pool.accTFTPerShare = pool.accTFTPerShare.add(
                    tftReward.mul(ACC_TFT_PRECISION).div(lpSupply)
                );
                tft.mint(address(this), tftReward);
            }
            pool.lastRewardBlock = block.number;
            poolInfo[_pid] = pool;
            emit LogUpdatePool(_pid, pool.lastRewardBlock, lpSupply, pool.accTFTPerShare);
        }
    }

    /**
     * @notice Update reward variables for all pools. Be careful of gas spending!
     *
     */
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo memory pool = poolInfo[pid];
            if (pool.allocPoint != 0) {
                updatePool(pid);
            }
        }
    }

    /**
     * @notice Deposit LP tokens to pool.
     * @param _pid: The id of the pool. See `poolInfo`.
     * @param _amount: Amount of LP tokens to deposit.
     * @param _to: The receiver of `amount` deposit benefit.
     *
     */
    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) external nonReentrant {
        require(_pid < lpToken.length, "TBCCMasterChef: pid is not found");

        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][_to];
        updatePool(_pid);
        // Effects
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.rewardDebt.add(_amount.mul(pool.accTFTPerShare).div(ACC_TFT_PRECISION));

        // Interactions
        IRewarder _rewarder = rewarder[_pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onTFTReward(_pid, _to, _to, 0, user.amount);
        }

        lpToken[_pid].safeTransferFrom(msg.sender, address(this), _amount);

        emit Deposit(msg.sender, _pid, _amount, _to);
    }

    /**
     * @notice Withdraw LP tokens from pool.
     * @param _pid: The id of the pool. See `poolInfo`.
     * @param _amount: Amount of LP tokens to withdraw.
     * @param _to: Receiver of the LP tokens.
     *
     */
    function withdraw(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) external nonReentrant {
        require(_pid < lpToken.length, "TBCCMasterChef: pid is not found");

        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);

        uint256 accumulatedTFT = user.amount.mul(pool.accTFTPerShare).div(ACC_TFT_PRECISION);
        uint256 _pendingTFT = accumulatedTFT.sub(user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedTFT.sub(_amount.mul(pool.accTFTPerShare).div(ACC_TFT_PRECISION));
        user.amount = user.amount.sub(_amount);

        // Interactions
        tft.transfer(_to, _pendingTFT);

        IRewarder _rewarder = rewarder[_pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onTFTReward(_pid, msg.sender, _to, _pendingTFT, user.amount);
        }

        lpToken[_pid].safeTransfer(_to, _amount);

        emit Withdraw(msg.sender, _pid, _amount, _to);
        emit Harvest(msg.sender, _pid, _pendingTFT);
    }

    /**
     * @notice Harvest proceeds for transaction sender to `to`.
     * @param _pid: The index of the pool. See `poolInfo`.
     * @param _to: Receiver of the TFT rewards.
     *
     */
    function harvest(
        uint256 _pid,
        address _to
    ) external {
        require(_pid < lpToken.length, "TBCCMasterChef: pid is not found");

        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 accumulatedTFT = user.amount.mul(pool.accTFTPerShare).div(ACC_TFT_PRECISION);
        uint256 _pendingTFT = accumulatedTFT.sub(user.rewardDebt);

        // Effects
        user.rewardDebt = accumulatedTFT;

        // Interactions
        if (_pendingTFT != 0) {
            tft.transfer(_to, _pendingTFT);
        }

        IRewarder _rewarder = rewarder[_pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onTFTReward(_pid, msg.sender, _to, _pendingTFT, user.amount);
        }

        emit Harvest(msg.sender, _pid, _pendingTFT);
    }

    /**
     * @notice Withdraw without caring about the rewards. EMERGENCY ONLY.
     * @param _pid: The id of the pool. See `poolInfo`.
     * @param _to: Receiver of the LP tokens.
     *
     */
    function emergencyWithdraw(
        uint256 _pid,
        address _to
    ) external nonReentrant {
        require(_pid < lpToken.length, "TBCCMasterChef: pid is not found");

        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        IRewarder _rewarder = rewarder[_pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onTFTReward(_pid, msg.sender, _to, 0, 0);
        }

        // Note: transfer can fail or succeed if `amount` is zero.
        lpToken[_pid].safeTransfer(_to, amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount, _to);
    }

    /**
     * @notice Add new bonus
     * @param _startBlock: New TFT per block
     *
     * @dev Callable by owner
     *
     */
    function addNewBonus(
        uint256 _startBlock,
        uint256 _bonus
    ) external onlyOwner {
        bonuses.push(BonusInfo(_startBlock, _bonus));
        massUpdatePools();
        emit AddNewBonus(_startBlock, _bonus);
    }

    /**
     * @notice It transfers the ownership of the TFT contract to a new address.
     * @param _newOwner: New TFT owner
     *
     * @dev Callable by owner
     *
     */
    function changeOwnershipTFTContract(
        address _newOwner
    ) external onlyOwner {
        tft.transferOwnership(_newOwner);
    }

    /**
     * @notice Claiming TFT per TDA
     * @param _tokenId: New TFT owner
     *
     * @dev Callable by NFT TDA Holder
     *
     */
    function apesClaim(
        uint256 _tokenId
    ) external onlyNFTTDAHolder(msg.sender, _tokenId) {
        require(tdaClaimed[_tokenId] == address(0), "TBCCMasterChef: TBCC TDA already claimed");

        // Interactions
        tdaClaimed[_tokenId] = msg.sender;
        tft.mint(msg.sender, claimAmount);
        emit NFTTDAClaimed(msg.sender, _tokenId, claimAmount);
    }

    /**
     * @notice Setting Claim amount for TFT per TDA
     * @param _newAmount: New TFT amount
     *
     * @dev Callable by owner
     *
     */
    function setApesClaimAmount(
        uint256 _newAmount
    ) external onlyOwner {
        claimAmount = _newAmount;
        emit NewClaimApesAmount(_newAmount);
    }
}

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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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
pragma solidity ^0.8.4;
pragma abicoder v2;

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
    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

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
     * @dev Destroys `amount` tokens from the caller.
     *
     */
    function burn(uint tokens) external returns (bool);

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
pragma solidity ^0.8.4;
pragma abicoder v2;

import "./IBEP20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance =
        token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
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

        bytes memory returndata =
        address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeBEP20: BEP20 operation did not succeed"
            );
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IRewarder {
    function onTFTReward(
        uint256 _pid,
        address _user,
        address _recipient,
        uint256 _tbccAmount,
        uint256 _newLpAmount
    ) external;

    function pendingTokens(
        uint256 _pid,
        address _user,
        uint256 _sushiAmount
    ) external view returns (address[] memory, uint256[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITBCCMasterChef {

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        uint256 accTFTPerShare;
        uint256 lastRewardBlock;
        uint256 allocPoint;
    }

    struct BonusInfo {
        uint256 startBlock;
        uint256 bonus;
    }

    /**
     * @notice Returns the number of TBCCMCV pools.
     *
     */
    function poolLength() external view returns (uint256);

    /**
     * @notice Migrate LP token to another LP contract through the `migrator` contract.
     * @param _pid: The index of the pool. See `poolInfo`.
     *
     */
    function migrate(
        uint256 _pid
    ) external;

    /**
     * @notice Return reward multiplier over the given _from to _to block.
     * @param _from: Start block
     * @param _to: End Block
     *
     */
    function getMultiplier(
        uint256 _from,
        uint256 _to
    ) external view returns (uint256);

    /**
     * @notice View function for checking pending TBCC rewards.
     * @param _pid: The id of the pool. See `poolInfo`.
     * @param _user: Address of the user.
     *
     */
    function pendingReward(
        uint256 _pid,
        address _user
    ) external view returns (uint256);

    /**
     * @notice Update reward variables for all pools. Be careful of gas spending!
     *
     */
    function massUpdatePools() external;

    /**
     * @notice Update reward variables for the given pool.
     * @param _pid: The id of the pool. See `poolInfo`.
     *
     */
    function updatePool(
        uint256 _pid
    ) external returns (PoolInfo memory);

    /**
     * @notice Deposit LP tokens to pool.
     * @param _pid: The id of the pool. See `poolInfo`.
     * @param _amount: Amount of LP tokens to deposit.
     * @param _to: The receiver of `amount` deposit benefit.
     *
     */
    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) external;

    /**
     * @notice Withdraw LP tokens from pool.
     * @param _pid: The id of the pool. See `poolInfo`.
     * @param _amount: Amount of LP tokens to withdraw.
     * @param _to: Receiver of the LP tokens.
     *
     */
    function withdraw(
        uint256 _pid,
        uint256 _amount,
        address _to
    ) external;

    /**
     * @notice Harvest proceeds for transaction sender to `to`.
     * @param _pid: The index of the pool. See `poolInfo`.
     * @param _to: Receiver of the TBCC rewards.
     *
     */
    function harvest(
        uint256 _pid,
        address _to
    ) external;

    /**
     * @notice Withdraw without caring about the rewards. EMERGENCY ONLY.
     * @param _pid: The id of the pool. See `poolInfo`.
     * @param _to: Receiver of the LP tokens.
     *
     */
    function emergencyWithdraw(
        uint256 _pid,
        address _to
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITFT is IERC20 {

    /**
     * @notice Mint tokens.
     * @param _to: recipient address
     * @param _amount: amount of tokens
     *
     * @dev Callable by owner
     *
     */
    function mint(
        address _to,
        uint256 _amount
    ) external;

    /**
     * @notice Burn tokens.
     * @param _amount: amount of tokens
     *
     * @dev Callable by owner
     *
     */
    function burn(
        uint256 _amount
    ) external;

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external virtual;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ITBCCDEFIAPES {
    /**
     * @notice Mint NFT
     * @param _mintAmount: NFT amount
     */
    function mintNFT(
        uint256 _mintAmount
    ) external payable;

    /**
     * @notice Mint NFT for Address
     * @param _mintAmount: NFT amount
     * @param _receiver: receiver address
     * @dev Callable by owner
     */
    function mintForAddress(
        uint256 _mintAmount,
        address _receiver
    ) external;

    /**
     * @notice Getting NFT for Wallet
     * @param _owner: wallet Address
     */
    function walletOfOwner(
        address _owner
    ) external view returns (uint256[] memory);

    /**
     * @notice Setting new NFT cost
     * @param _cost: new cost
     * @dev Callable by owner
     */
    function setCost(
        uint256 _cost
    ) external;

    /**
     * @notice Setting new max supply
     * @param _maxSupply: new max supply
     * @dev Callable by owner
     */
    function setMaxSupply(
        uint256 _maxSupply
    ) external;

    /**
     * @notice Setting new IRI Prefix
     * @param _uriPrefix: new prefix
     * @dev Callable by owner
     */
    function setUriPrefix(
        string memory _uriPrefix
    ) external;

    /**
     * @notice Setting new IRI suffix
     * @param _uriSuffix: new suffix
     * @dev Callable by owner
     */
    function setUriSuffix(
        string memory _uriSuffix
    ) external;

    /**
     * @notice Setting contract pause
     * @param _state: pause state
     * @dev Callable by owner
     */
    function setPaused(
        bool _state
    ) external;

    /**
     * @notice withdraw
     * @dev Callable by owner
     */
    function withdraw() external;

    /**
     * @notice withdraw Background
     * @dev Callable by owner
     */
    function withdrawBUSD()  external;

    /**
     * @notice Get Claim Amount
     */
    function getClaimAmount() external view returns (uint256);

    /**
     * @notice Burn NFT
     * @param _tokenId: token id
     */
    function burnNFT(
        uint256 _tokenId
    ) external;

    /**
     * @notice Setting Fee Handler
     * @param _feeHandler: feeHandler address
     */
    function setFeeHandler(
        address _feeHandler
    ) external;

    /**
     * @notice See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) external view returns (address);

    /**
     * @notice Burned tokens are calculated here, use _totalMinted() if you want to count just minted tokens.
     */
    function totalSupply() external view returns (uint256);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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