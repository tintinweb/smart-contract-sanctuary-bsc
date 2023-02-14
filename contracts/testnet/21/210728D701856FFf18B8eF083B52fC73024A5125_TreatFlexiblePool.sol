// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITreatToken is IERC20, IERC20Metadata {
    function getPastVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint256);

    function executeStaking(
        address account,
        uint256 transferAmount
    ) external returns (
        uint256 lockedAmount,
        uint256 remainingVestingProgress
    );

    function executeWithdrawal(
        address account,
        uint256 transferAmount,
        uint256 lockedAmount,
        uint256 remainingVestingProgress
    ) external;

    function viewNotVestedTokens(address recipient) external view
        returns(uint256 locked, uint256 remainingVestingTime);

    function setExchangeAddress(
        address _factory,
        address tokenB
    ) external;
    function isExchangeAddress(address pair) external view returns(bool);

    function mint(address to, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {updateOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract SafeOwnable is Context {
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipUpdated(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = _msgSender();
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
        _owner = address(0);
    }

    /**
     * @dev Allows newOwner to claim ownership
     * @param newOwner Address that should become a new owner
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to msg.sender
     */
    function updateOwnership() external {
        _updateOwnership();
    }

    /**
     * @dev Allows newOwner to claim ownership
     * @param newOwner Address that should become a new owner
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _newOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to msg.sender
     * Internal function without access restriction.
     */
    function _updateOwnership() private {
        address oldOwner = _owner;
        address newOwner = _newOwner;
        require(msg.sender == newOwner, "Not a new owner");
        require(oldOwner != newOwner, "Already updated");
        _owner = newOwner;
        emit OwnershipUpdated(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./SafeOwnable.sol";
import "./VestingManager.sol";
import "./ITreatToken.sol";

// @title Stake Treat -> earn Treat pool which allows multiple deposits of Treat tokens
contract TreatFlexiblePool is SafeOwnable {
    struct DepositInfo {
        uint256 amount;                         // Amount of stake shares the user has for staking
        uint256 pendingRewards;                 // Amount of pending rewards
        uint256 lastUpdateAccTokenPerShare;     // Value of accTokenPerShare during last deposit update
    }

    // struct for view function
    struct ExtendedDepositInfo {
        uint64 depositId;           // ID index of deposit
        uint256 amount;             // Amount of stake tokens the user has deposited
        uint256 pendingRewards;     // Amount of pending rewards
        uint256 rewardsPerDay;      // Amount of reward tokens user is receiving per day for this deposit
        uint256 lastUpdateAccTokenPerShare;   // Last value of accTokenPerShare during last deposit update
        uint256 locked;                 // Amount of locked tokens
        uint256 remainingVestingTime;   // Remaining vesting duration
    }

    uint256 private constant BLOCKS_PER_DAY = 1200 * 24;
    uint256 public constant PRECISION_FACTOR = 1e12;
    ITreatToken public immutable treatToken;
    // setting startBlock in distant future may prevent depositing while still distributing rewards
    uint32 public startBlock;
    uint32 public vestingDuration;
    uint32 public lastRewardBlock;
    uint128 public rewardPerBlock;
    uint256 public totalStaked;
    uint256 public accTokenPerShare;

    mapping(address => uint256) public totalUserStaked;  // Sum of user stake tokens
    //account => => depositId => VestingData
    mapping(address => mapping(uint256 => VestingManager.VestingData)) public tokenVesting;
    // account address => Array of user deposits
    mapping(address => DepositInfo[]) public deposits;


    event NewDeposit(
        address indexed account,
        uint32 depositId, // uint32 for gas saving
        uint256 amount
    );

    event DepositReplenishment(
        address account,
        bool harvestedRewards,
        uint32 depositId, // uint32 for gas saving
        uint256 amount,
        uint256 earnedRewards
    );

    event Withdrawal(
        address indexed account,
        bool harvestedRewards,
        uint32 depositId, // uint32 for gas saving
        uint256 amount,
        uint256 earnedRewards
    );

    event EmergencyWithdrawal(
        address indexed account,
        uint32 depositId, // uint32 for gas saving
        uint256 amount
    );

    event RewardsHarvest(address account, uint256 amount);

    event NewRewardPerBlock(uint128);
    event NewStartBlock(uint32);
    event NewVestingDuration(uint32);

    /*
     * @notice Initialize the contract
     * @param _treatToken Treat token address
     * @param _startBlock Pool start block
     * @param _rewardPerBlock Pool rewards per block amount
     * @param _vestingDuration Treat token vesting duration for the pool
     */
    constructor(
        ITreatToken _treatToken,
        uint32 _startBlock,
        uint128 _rewardPerBlock,
        uint32 _vestingDuration
    ){
        require(address(_treatToken) != address(0));
        require(_vestingDuration != 0);
        treatToken = _treatToken;
        startBlock = _startBlock;
        rewardPerBlock = _rewardPerBlock;
        vestingDuration = _vestingDuration;
    }

    /*
     * @notice Creates NEW deposit
     * @param amount Amount of tokens to deposit
     */
    function newDeposit(uint256 amount) external {
        require(block.number >= startBlock, "Pool is not active");
        require(rewardPerBlock > 0, "Pool has ended");

        _updatePool();

        deposits[msg.sender].push(DepositInfo({
            amount: amount,
            pendingRewards: 0,
            lastUpdateAccTokenPerShare: accTokenPerShare
        }));

        uint256 depositId = deposits[msg.sender].length - 1;
        _executeStaking(
            msg.sender,
            depositId,
            amount
        );

        emit NewDeposit(
            msg.sender,
            uint32(depositId),
            amount
        );
    }

    /*
     * @notice Replenish existing deposit
     * @param depositId ID index of deposit to replenish
     * @param amount Amount of tokens to add to deposit
     * @param shouldHarvestRewards Should user receive owned rewards?
     * true - immediately receive rewards, false - harvest rewards later
     */
    function replenishDeposit(
        uint256 depositId,
        uint256 amount,
        bool shouldHarvestRewards
    ) external {
        require(block.number >= startBlock, "Pool is not active");
        require(rewardPerBlock > 0, "Pool has ended");
        DepositInfo memory userDeposit = deposits[msg.sender][depositId];

        _updatePool();

        uint256 pendingRewards = userDeposit.pendingRewards + userDeposit.amount
            * (accTokenPerShare - userDeposit.lastUpdateAccTokenPerShare)
            / PRECISION_FACTOR;

        deposits[msg.sender][depositId].amount += amount;
        deposits[msg.sender][depositId].lastUpdateAccTokenPerShare = accTokenPerShare;

        _executeStaking(
            msg.sender,
            depositId,
            amount
        );

        // mint rewards after staking to avoid increasing locked amount in users wallet
        if(shouldHarvestRewards && pendingRewards > 0) {
            treatToken.mint(msg.sender, pendingRewards);
            deposits[msg.sender][depositId].pendingRewards = 0;
        } else {
            deposits[msg.sender][depositId].pendingRewards = pendingRewards;
        }

        emit DepositReplenishment(
            msg.sender,
            shouldHarvestRewards,
            uint32(depositId),
            amount,
            pendingRewards
        );
    }


    /*
     * @notice Withdraws funds from specific user's deposit
     * @param depositId ID index of the deposit
     * @param amount Amount of tokens to withdraw
     * @param shouldHarvestRewards Should user receive owned rewards?
     * true - immediately receive rewards, false - harvest rewards later
     */
    function withdraw(
        uint256 depositId,
        uint256 amount,
        bool shouldHarvestRewards
    ) external {
        require(deposits[msg.sender].length > depositId, "Invalid deposit ID");
        DepositInfo storage userDeposit = deposits[msg.sender][depositId];
        uint256 depositAmount = userDeposit.amount;
        require(depositAmount >= amount, "Over deposit amount");

        _updatePool();

        uint256 pendingRewards = userDeposit.pendingRewards + depositAmount
            * (accTokenPerShare - userDeposit.lastUpdateAccTokenPerShare)
            / PRECISION_FACTOR;

        userDeposit.amount = depositAmount - amount;
        userDeposit.lastUpdateAccTokenPerShare = accTokenPerShare;

        _executeWithdrawal(
            msg.sender,
            depositId,
            amount,
            depositAmount,
            vestingDuration
        );

        if(shouldHarvestRewards && pendingRewards > 0) {
            treatToken.mint(msg.sender, pendingRewards);
            deposits[msg.sender][depositId].pendingRewards = 0;
        } else {
            deposits[msg.sender][depositId].pendingRewards = pendingRewards;
        }


        emit Withdrawal(
            msg.sender,
            shouldHarvestRewards,
            uint32(depositId),
            amount,
            pendingRewards
        );
    }


    /*
     * @notice Withdraws deposit without collecting rewards. For EMERGENCY use only
     * @param depositId ID index of the deposit
     * @dev Should be used only if there is a problem withdrawing deposit with collecting rewards
     */
    function emergencyWithdraw(uint256 depositId) external {
        require(deposits[msg.sender].length > depositId, "Invalid deposit ID");
        DepositInfo memory userDeposit = deposits[msg.sender][depositId];
        require(userDeposit.amount > 0, "Nothing to withdraw");

        uint256 pendingRewards = userDeposit.pendingRewards + userDeposit.amount
            * (accTokenPerShare - userDeposit.lastUpdateAccTokenPerShare)
            / PRECISION_FACTOR;

        deposits[msg.sender][depositId].amount = 0;
        deposits[msg.sender][depositId].pendingRewards = 0;

        _executeWithdrawal(
            msg.sender,
            depositId,
            userDeposit.amount,
            userDeposit.amount,
            vestingDuration
        );

        // distributing lost rewards among other users (just in case)
        if (pendingRewards > 0) {
            accTokenPerShare += pendingRewards * PRECISION_FACTOR / totalStaked;
        }

        emit EmergencyWithdrawal(
            msg.sender,
            uint32(depositId),
            userDeposit.amount
        );
    }


    /*
     * @notice Harvests rewards for multiple user deposits
     * @param depositIds Array of deposit ids to harvest rewards from
     * @return rewardsAmount amount of rewards harvested
     */
    function harvestRewards(
        uint256[] calldata depositIds
    ) public returns(uint256 rewardsAmount){
        _updatePool();

        rewardsAmount = 0;
        uint256 numberOfDeposits = deposits[msg.sender].length;
        for (uint i = 0; i < depositIds.length; i++) {
            require(depositIds[i] < numberOfDeposits, "Invalid deposit ID");
            DepositInfo storage userDeposit = deposits[msg.sender][depositIds[i]];
            uint256 pendingRewards = userDeposit.pendingRewards + userDeposit.amount
                * (accTokenPerShare - userDeposit.lastUpdateAccTokenPerShare)
                / PRECISION_FACTOR;

            userDeposit.lastUpdateAccTokenPerShare = accTokenPerShare;
            userDeposit.pendingRewards = 0;
            rewardsAmount += pendingRewards;
        }
        require(rewardsAmount > 0, "Nothing to harvest");

        treatToken.mint(msg.sender, rewardsAmount);

        emit RewardsHarvest(msg.sender, rewardsAmount);
    }


    /*
     * @notice Sets pool values
     * @param _rewardPerBlock Amount of rewards per block for the pool
     * @param _startBlock Start block. Deposits are not allowed before this block
       Setting start block in far future will allow to forbid depositing while keeping rewards distribution
     * @param _vestingDuration Time during which Treat token is fully vested
     * @dev Only Owner
     */
    function setPoolValues(
        uint128 _rewardPerBlock,
        uint32 _startBlock,
        uint32 _vestingDuration
    ) external onlyOwner {

        if (rewardPerBlock != _rewardPerBlock) {
            setRewardPerBlock(_rewardPerBlock);
        }

        if (startBlock != _startBlock) {
            setStartBlock(_startBlock);
        }

        if (vestingDuration != _vestingDuration) {
            setVestingDuration(_vestingDuration);
        }
    }


    /*
     * @notice Sets amount of rewards per block for the pool
     * @param _rewardPerBlock Amount of rewards per block for the pool
     * @dev Only Owner
     */
    function setRewardPerBlock(uint128 _rewardPerBlock) public onlyOwner {
        require(rewardPerBlock != _rewardPerBlock, "Already set");
        _updatePool();
        rewardPerBlock = _rewardPerBlock;
        emit NewRewardPerBlock(_rewardPerBlock);
    }


    /*
     * @notice Sets pool start block. Deposits are not allowed before this block
       Setting start block in far future will allow to forbid depositing while keeping rewards distribution
     * @param _startBlock Start block
     * @dev Only Owner
     */
    function setStartBlock(uint32 _startBlock) public onlyOwner {
        require(startBlock != _startBlock, "Already set");
        startBlock = _startBlock;
        emit NewStartBlock(_startBlock);
    }


    /*
     * @notice Sets vesting duration.
     * @param _eliminationPeriodDuration Time during which Treat token is fully vested
     * @dev Only Owner
     */
    function setVestingDuration(uint32 _vestingDuration) public onlyOwner {
        require(vestingDuration != _vestingDuration, "Already set");
        require(_vestingDuration != 0, "Invalid vesting duration");
        vestingDuration = _vestingDuration;
        emit NewVestingDuration(_vestingDuration);
    }


    /*
     * @notice Returns most of pools variables in a single call
     * @return token Treat token address
     * @return startBlock Start block of the pool
     * @return lastRewardBlock Last reward block
     * @return rewardPerBlock Rewards per block amount
     * @return totalStaked Total amount of tokens staked
     * @return vestingDuration Vesting duration
     */
    function getPoolData() external view returns(
        address token,
        uint256 _startBlock,
        uint256 _lastRewardBlock,
        uint256 _rewardPerBlock,
        uint256 _totalStaked,
        uint256 _vestingDuration
    ) {

        return (
            address(treatToken),
            startBlock,
            lastRewardBlock,
            rewardPerBlock,
            totalStaked,
            vestingDuration
        );
    }


    /*
     * @notice Collects deposit data
     * @param account User account address
     * @param depositId DepositId
     * @return depositData Deposit data
     */
    function getDepositData(
        address account,
        uint256 depositId
    ) external view returns (ExtendedDepositInfo memory depositData) {
        uint256 newAccTokenPerShare = _newAccTokenPerShare();
        require(deposits[account].length > depositId, "Invalid deposit ID");

        return _getDepositData(
            account,
            depositId,
            newAccTokenPerShare,
            vestingDuration,
            totalStaked
        );
    }


    /*
     * @notice Returns collected user info
     * @param account User account address
     * @return totalAccountStaked Total user staked
     * @return totalPendingRewards Total amount of pending rewards for all deposits
     * @return totalRewardsPerDay Total rewards per day that user receives for all deposits
     * @return totalTreatTokensLocked Total TreatTokens locked
     * @return depositsData Extended deposit data
     */
    function getUserInfo(address account) external view
    returns (
        uint256 totalAccountStaked,
        uint256 totalPendingRewards,
        uint256 totalRewardsPerDay,
        uint256 totalTreatTokensLocked,
        ExtendedDepositInfo[] memory depositsData
    ) {
        totalAccountStaked = totalUserStaked[account];
        totalPendingRewards = 0;
        totalRewardsPerDay = 0;
        totalTreatTokensLocked = 0;
        depositsData = new ExtendedDepositInfo[](deposits[account].length);

        uint256 newAccTokenPerShare = _newAccTokenPerShare();

        for(uint i = 0; i < deposits[account].length; i++) {
            depositsData[i] = _getDepositData(
                account,
                i,
                newAccTokenPerShare,
                vestingDuration,
                totalStaked
            );
            totalPendingRewards += depositsData[i].pendingRewards;
            totalRewardsPerDay += depositsData[i].rewardsPerDay;
            totalTreatTokensLocked += depositsData[i].locked;
        }
    }


    /*
     * @notice Updates pool variables
     */
    function _updatePool() private {
        if (block.number <= lastRewardBlock) {
            return;
        }

        if (totalStaked == 0) {
            lastRewardBlock = uint32(block.number);
            return;
        }

        uint256 newRewards = (block.number - uint256(lastRewardBlock)) * uint256(rewardPerBlock);
        accTokenPerShare += newRewards * PRECISION_FACTOR / totalStaked;
        lastRewardBlock = uint32(block.number);
    }


    /*
     * @notice Executes proper Treat token staking. Updates vesting data
     * @return account Deposit owner
     * @return depositId Deposit id
     * @return stakeAmount Stake amount to withdraw
     */
    function _executeStaking(
        address account,
        uint256 depositId,
        uint256 amount
    ) private {
        totalUserStaked[account] += amount;
        totalStaked += amount;

        (
            uint256 lockedAmount,
            uint256 remainingVestingProgress
        ) = treatToken.executeStaking(account, amount);

        uint256 _vestingDuration = vestingDuration;

        VestingManager.vestingUpdate(
            tokenVesting[account][depositId],
            _vestingDuration
        );

        VestingManager.addVesting(
            tokenVesting[account][depositId],
            _vestingDuration,
            lockedAmount,
            remainingVestingProgress
        );
    }


    /*
     * @notice Executes proper withdrawal
     * @param account Deposit owner
     * @param depositId Deposit id
     * @param amount Stake amount to withdraw
     * @param depositAmount Deposit amount
     * @param _vestingDuration Vesting duration for the deposit
     */
    function _executeWithdrawal(
        address account,
        uint256 depositId,
        uint256 amount,
        uint256 depositAmount,
        uint256 _vestingDuration
    ) private {
        totalUserStaked[account] -= amount;
        totalStaked -= amount;

        (uint256 locked, uint256 remainingVestingTime) = VestingManager.vestingUpdate(
            tokenVesting[account][depositId],
            _vestingDuration
        );

        uint256 lockedTransfer = locked * amount / depositAmount;
        tokenVesting[account][depositId].amount -= lockedTransfer;

        treatToken.executeWithdrawal(
            account,
            amount,
            lockedTransfer,
            remainingVestingTime * 1e9 / _vestingDuration
        );
    }


    /*
     * @notice Collects deposit data
     * @param account User account address
     * @param depositId DepositId
     * @param newAccTokenPerShare Updated `accTokenPerShare`
     * @param _vestingDuration Vesting duration
     * @param _totalStaked Total tokens staked
     * @return depositData Extended deposit info
     */
    function _getDepositData(
        address account,
        uint256 depositId,
        uint256 newAccTokenPerShare,
        uint256 _vestingDuration,
        uint256 _totalStaked
    ) internal view returns (ExtendedDepositInfo memory depositData) {
        DepositInfo memory userDeposit = deposits[account][depositId];

        uint256 pendingRewards = userDeposit.pendingRewards + userDeposit.amount
            * (newAccTokenPerShare - userDeposit.lastUpdateAccTokenPerShare) / PRECISION_FACTOR;

        uint256 rewardsPerDay = 0;

        if (userDeposit.amount > 0) {
            rewardsPerDay = BLOCKS_PER_DAY * uint256(rewardPerBlock)
                * userDeposit.amount / _totalStaked;
        }

        (uint256 locked, uint256 remainingVestingTime) = VestingManager.getLockedAndRemaining(
            tokenVesting[account][depositId],
            _vestingDuration
        );

        return ExtendedDepositInfo({
            depositId: uint64(depositId),
            amount: userDeposit.amount,
            pendingRewards: pendingRewards,
            rewardsPerDay: rewardsPerDay,
            lastUpdateAccTokenPerShare: userDeposit.lastUpdateAccTokenPerShare,
            locked: locked,
            remainingVestingTime: remainingVestingTime
        });
    }


    /*
     * @notice Calculates updated accTokenPerShare value
     * @return newAccTokenPerShare Updated accTokenPerShare value
     * @dev Should be used ONLY for view functions
     */
    function _newAccTokenPerShare() private view returns (uint256 newAccTokenPerShare) {
        newAccTokenPerShare = accTokenPerShare;
        uint256 _lastRewardBlock = lastRewardBlock;
        uint256 _rewardPerBlock = rewardPerBlock;
        if (totalStaked > 0 && _rewardPerBlock > 0 && block.number > _lastRewardBlock) {
            uint256 newRewards = (block.number - _lastRewardBlock) * _rewardPerBlock;
            newAccTokenPerShare += newRewards * PRECISION_FACTOR / totalStaked;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// @title Library for managing vesting storage data.
// Must be used by staking smart contracts with Treat Token as deposit token
library VestingManager {
    struct VestingData {
        uint32 time;            // end of vesting timestamp
        uint32 lastUpdateTime;  // last vesting update timestamp
        uint256 amount;         // amount of tokens being vested
    }

    /*
     * @title Updates vesting data: end of vesting, amount of tokens has not been vested yet
     * @param vestingStorage Vesting data storage
     * @param vestingDuration Vesting duration for this vesting data
     * @return locked Amount of locked tokens
     * @return remainingVestingTime Remaining vesting duration
     */
    function vestingUpdate(
        VestingData storage vestingStorage,
        uint256 vestingDuration
    ) internal returns (uint256 locked, uint256 remainingVestingTime){
        VestingData memory vestingMemory = vestingStorage;
        (locked, remainingVestingTime) = getLockedAndRemaining(
            vestingMemory,
            vestingDuration
        );

        // update if needed
        if (vestingMemory.lastUpdateTime != uint32(block.timestamp)) {
            vestingStorage.lastUpdateTime = uint32(block.timestamp);
        }
        if (
            remainingVestingTime != 0
            && vestingMemory.time != uint32(block.timestamp + remainingVestingTime)
        ) {
            vestingStorage.time = uint32(block.timestamp + remainingVestingTime);
        }
        if (vestingMemory.amount != locked) {
            vestingStorage.amount = locked;
        }
    }


    /*
     * @title Adds new unvested tokens to vesting storage. Calculates remaining vesting time as weighted average.
     * @param vestingStorage Vesting data storage
     * @param vestingDuration Vesting duration for this vesting data
     * @param lockedAmount Amount of locked tokens to be added
     * @param remainingVestingProgress Remaining percentage of vesting duration for arriving tokens, where 1e9 == 100%
     * If tokens are fully unvested `remainingVestingProgress` = 1e9
     * If tokens are half vested `remainingVestingProgress` = 0.5 * 1e9
     * Should be calculated as {remainingVestingTime * 1e9 / vestingDuration}
     * @return locked Amount of locked tokens
     * @return remainingVestingTime Remaining vesting duration
     * @dev Must be used after vestingUpdate()
     */
    function addVesting(
        VestingData storage vestingStorage,
        uint256 vestingDuration,
        uint256 lockedAmount,
        uint256 remainingVestingProgress
    ) internal returns (uint256 locked, uint256 remainingVestingTime) {
        // gas savings
        VestingData memory vestingMemory = vestingStorage;
        require(vestingMemory.lastUpdateTime == uint32(block.timestamp), "vestingUpdate first");
        // calculate remaining time with weighted average
        uint256 storageRemainingTime = block.timestamp < vestingMemory.time
            ? vestingMemory.time - block.timestamp
            : 0;
        if(lockedAmount == 0) {
            return (vestingMemory.amount, storageRemainingTime);
        }
        uint256 remainingAddedDuration = vestingDuration * remainingVestingProgress / 1e9;
        remainingVestingTime = (lockedAmount * remainingAddedDuration + vestingMemory.amount * storageRemainingTime)
            / (lockedAmount + vestingMemory.amount);
        locked = vestingMemory.amount + lockedAmount;

        // update vesting data
        vestingStorage.time = uint32(block.timestamp + remainingVestingTime);
        vestingStorage.amount = locked;
    }


    /*
     * @title Calculates vesting data: end of vesting, amount of tokens has not been vested yet
     * @param vestingData Vesting data
     * @param vestingDuration Vesting duration for this vesting data
     * @return locked Amount of locked tokens
     * @return remainingVestingTime Remaining vesting duration
     */
    function getLockedAndRemaining(
        VestingData memory vestingData,
        uint256 vestingDuration
    ) internal view returns (uint256 locked, uint256 remainingVestingTime) {
        remainingVestingTime = 0;
        locked = 0;

        if (vestingData.amount == 0) {
            return (0,0);
        } else {
            uint256 maxEndTime = vestingData.lastUpdateTime + vestingDuration;
            if (vestingData.time > maxEndTime) {
                vestingData.time = uint32(maxEndTime);
            }

            // If vesting time is over
            if (vestingData.time <= block.timestamp) {
                return (0,0);
            }

            remainingVestingTime = vestingData.time - block.timestamp;
            uint256 sinceLastUpdate = block.timestamp - vestingData.lastUpdateTime;
            locked = vestingData.amount * remainingVestingTime / (sinceLastUpdate + remainingVestingTime);
        }
    }
}