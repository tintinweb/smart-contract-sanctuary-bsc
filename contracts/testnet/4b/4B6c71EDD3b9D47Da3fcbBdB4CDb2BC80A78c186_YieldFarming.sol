// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import './core/farms/MasterChef.sol';
import './ReferralProgram.sol';

contract YieldFarming is MasterChef {
    using SafeMath for uint256;

    // address of the ref contract
	address public referralProgramAddress;

    constructor(
        EvxToken _evx,
        address _devaddr,
        uint256 _evxPerBlock,
        uint256 _startBlock,
        address _referralProgramAddress
    ) MasterChef(_evx, _devaddr, _evxPerBlock, _startBlock) {
        referralProgramAddress = _referralProgramAddress;
    }

    function deposit(uint256 _pid, uint256 _amount, address _parentRefAddress) public {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][msg.sender];
        uint256 pending = user.amount.mul(pool.accEvxPerShare).div(1e12).sub(user.rewardDebt);
        ReferralProgram(referralProgramAddress).accrue(ReferralProgram.SourceRefContract.FixedStaking, pending, _parentRefAddress, msg.sender);
        super.deposit(_pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount, address _parentRefAddress) public {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][msg.sender];
        uint256 pending = user.amount.mul(pool.accEvxPerShare).div(1e12).sub(user.rewardDebt);
        ReferralProgram(referralProgramAddress).accrue(ReferralProgram.SourceRefContract.FixedStaking, pending, _parentRefAddress, msg.sender);
        super.withdraw(_pid, _amount);
    }

    function enterStaking(uint256 _amount, address _parentRefAddress) public {
        PoolInfo memory pool = poolInfo[0];
        UserInfo memory user = userInfo[0][msg.sender];
        uint256 pending = user.amount.mul(pool.accEvxPerShare).div(1e12).sub(user.rewardDebt);
        ReferralProgram(referralProgramAddress).accrue(ReferralProgram.SourceRefContract.FixedStaking, pending, _parentRefAddress, msg.sender);
        super.enterStaking(_amount);
    }

    function leaveStaking(uint256 _amount, address _parentRefAddress) public {
        PoolInfo memory pool = poolInfo[0];
        UserInfo memory user = userInfo[0][msg.sender];
        uint256 pending = user.amount.mul(pool.accEvxPerShare).div(1e12).sub(user.rewardDebt);
        ReferralProgram(referralProgramAddress).accrue(ReferralProgram.SourceRefContract.FixedStaking, pending, _parentRefAddress, msg.sender);
        super.leaveStaking(_amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../EvxToken.sol";

interface IMigratorChef {
    function migrate(ERC20 token) external returns (ERC20);
}

// MasterChef is the master of EVX. He can make EVX and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once EVX is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of EVXs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accEvxPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accEvxPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        ERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. EVXs to distribute per block.
        uint256 lastRewardBlock; // Last block number that EVXs distribution occurs.
        uint256 accEvxPerShare; // Accumulated EVXs per share, times 1e12. See below.
    }

    // The EVX TOKEN!
    EvxToken public evx;
    // Dev address.
    address public devaddr;
    // EVX tokens created per block.
    uint256 public evxPerBlock;
    // Bonus muliplier for early evx makers.
    uint256 public BONUS_MULTIPLIER = 1;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigratorChef public migrator;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when EVX mining starts.
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        EvxToken _evx,
        address _devaddr,
        uint256 _evxPerBlock,
        uint256 _startBlock
    ) {
        evx = _evx;
        devaddr = _devaddr;
        evxPerBlock = _evxPerBlock;
        startBlock = _startBlock;

        // staking pool
        poolInfo.push(PoolInfo({lpToken: _evx, allocPoint: 1000, lastRewardBlock: startBlock, accEvxPerShare: 0}));

        totalAllocPoint = 1000;
    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        ERC20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({lpToken: _lpToken, allocPoint: _allocPoint, lastRewardBlock: lastRewardBlock, accEvxPerShare: 0})
        );
        updateStakingPool();
    }

    // Update the given pool's EVX allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
            updateStakingPool();
        }
    }

    function updateStakingPool() internal {
        uint256 length = poolInfo.length;
        uint256 points = 0;
        for (uint256 pid = 1; pid < length; ++pid) {
            points = points.add(poolInfo[pid].allocPoint);
        }
        if (points != 0) {
            points = points.div(3);
            totalAllocPoint = totalAllocPoint.sub(poolInfo[0].allocPoint).add(points);
            poolInfo[0].allocPoint = points;
        }
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        ERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        ERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending EVXs on frontend.
    function pendingEvx(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accEvxPerShare = pool.accEvxPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 evxReward = multiplier.mul(evxPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accEvxPerShare = accEvxPerShare.add(evxReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accEvxPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 evxReward = multiplier.mul(evxPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        evx.distributeByYieldFarming(devaddr, evxReward.div(10));
        evx.distributeByYieldFarming(address(this), evxReward);
        pool.accEvxPerShare = pool.accEvxPerShare.add(evxReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for EVX allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        require(_pid != 0, "deposit EVX by staking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accEvxPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeEvxTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accEvxPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        require(_pid != 0, "withdraw EVX by unstaking");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accEvxPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeEvxTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accEvxPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Stake EVX tokens to MasterChef
    function enterStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accEvxPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeEvxTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accEvxPerShare).div(1e12);

        emit Deposit(msg.sender, 0, _amount);
    }

    // Withdraw EVX tokens from STAKING.
    function leaveStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
        uint256 pending = user.amount.mul(pool.accEvxPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeEvxTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accEvxPerShare).div(1e12);

        emit Withdraw(msg.sender, 0, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Safe EVX transfer function, just in case if rounding error causes pool to not have enough EVXs.
    function safeEvxTransfer(address _to, uint256 _amount) internal {
        evx.transfer(_to, _amount);
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './EvxToken.sol';

/**
 * @title Referral program for:
 * - staking
 * - fixed staking
 * - swaps
 * - yield farming
 */
contract ReferralProgram is Ownable {
    // contract where user came from
    enum SourceRefContract {
        Swap,
        Staking,
        FixedStaking,
        YieldFarming
    }

    // fee amount for each referrer level
    // 100% = 1000000
    struct FeeLevel {
        uint level0;
        uint level1;
        uint level2;
        uint level3;
        uint level4;
    }

    // referrer level
    struct RefLevel {
        uint minLiquidityAmount; // min amount of liquidity that user should provide to open level
        uint refLevels; // number of levels from which user gets rewards
        mapping(SourceRefContract => FeeLevel) feeLevels; // fee level for all source ref contract types
    }

    // all available ref levels
    mapping (uint => RefLevel) public refLevels;

    // addresses which can accrue rewards (staking, fixed staking, swap, yield farming)
    mapping (address => bool) public whitelist;

    // child => parent ref hierarchy
    mapping (address => address) public childParentRefs;

    // reward token address
    address public rewardTokenAddress;

    // liquidity contract address
    address public liquidityAddress;

    // treasury address
    address public treasuryAddress;

    // address where tokens are sent for burning
    address public burnAddress;

    // % of reward sent to treasury address when ref level is closed, 100% = 1000000
    // NOTICE: feeRateTreasury + feeRateBurn = 100%
    uint public feeRateTreasury;

    // % of reward sent to burn address when ref level is closed, 100% = 1000000
    // NOTICE: feeRateTreasury + feeRateBurn = 100%
    uint public feeRateBurn;

    // % denominator
	uint constant DENOMINATOR = 1000000;

    // how to deep to search for refs
    uint constant REF_MAX_SEARCH_LEVEL = 5;

    // max number of ref levels
    uint constant REF_MAX_LEVEL_COUNT = 6;

    //===================
	// Public methods
	//===================

    /**
     * @notice Returns fee rate from ref level
     * @param _refLevelIndex ref level index
     * @param _sourceRefContract where call to accrue interest was originated
     * @param _feeLevel fee level to search for
     * @return feeRate fee rate for ref level
     */
    function getFeeRateFromRefLevel(
        uint _refLevelIndex,
        SourceRefContract _sourceRefContract,
        uint _feeLevel
    ) 
        public 
        view
        returns(uint) 
    {
        // validation
        require(_refLevelIndex < REF_MAX_LEVEL_COUNT, 'INVALID_REF_LEVEL');
        require(_feeLevel >= 0 && _feeLevel < REF_MAX_SEARCH_LEVEL, 'INFALID_FEE_LEVEL');
        // return fee rate
        uint feeRate = refLevels[_refLevelIndex].feeLevels[_sourceRefContract].level0;
        if (_feeLevel == 1) feeRate = refLevels[_refLevelIndex].feeLevels[_sourceRefContract].level1;
        if (_feeLevel == 2) feeRate = refLevels[_refLevelIndex].feeLevels[_sourceRefContract].level2;
        if (_feeLevel == 3) feeRate = refLevels[_refLevelIndex].feeLevels[_sourceRefContract].level3;
        if (_feeLevel == 4) feeRate = refLevels[_refLevelIndex].feeLevels[_sourceRefContract].level4;
        return feeRate;
    }

    /**
     * @notice Returns ref level index for target address
     * @param _targetAddress target address
     * @return refLevelIndex target address ref level index
     */
    function getRefLevelIndex(address _targetAddress) public view returns(uint) {
        // get amount of liquidity tokens
        uint balance = IERC20(liquidityAddress).balanceOf(_targetAddress);
        // by default set ref level 0
        uint refLevelIndex = 0;
        // find ref level
        for (uint i = REF_MAX_SEARCH_LEVEL; i > 0; i--) {
            if (balance >= refLevels[i].minLiquidityAmount) {
                refLevelIndex = i;
                break;
            }
        }
        // return result
        return refLevelIndex;
    }

    //=====================
	// Whitelist methods
	//=====================

    /**
     * @notice Accrues interest in reward tokens
     * @param _sourceRefContract where call was originated from
     * @param _amount amount for which to accrue interest
     * @param _parentRefAddress referrer address
     * @param _childRefAddress referral address
     */
    function accrue(
        SourceRefContract _sourceRefContract,
        uint _amount,
        address _parentRefAddress,
        address _childRefAddress
    )
        public
    {
        // validation
        require(whitelist[msg.sender], 'NOT_ALLOWED');
        // if there is no referrer then do not accrue interest
        if (_parentRefAddress == address(0)) return;
        // if amount is less than demoninator then user will get 0 tokens, skip
        if (_amount < DENOMINATOR) return;

        // set parent referrer for child
        childParentRefs[_childRefAddress] = _parentRefAddress;

        // accrue interest for all parents of the child
        address childAddress = _childRefAddress;
        for (uint feeLevel = 0; feeLevel < REF_MAX_SEARCH_LEVEL; feeLevel++) {
            // get parent address
            address parentAddress = childParentRefs[childAddress];
            // if parent address is empty then stop accrueing
            if (parentAddress == address(0)) break;

            // get parent ref level
            uint parentRefLevelIndex = getRefLevelIndex(parentAddress);
            // get fee rate
            uint feeRate = getFeeRateFromRefLevel(parentRefLevelIndex, _sourceRefContract, feeLevel);
            // if fee rate = 0 then there is nothing to accrue, continue
            if (feeRate == 0) continue;
            // get reward amount
            uint rewardAmount = _amount / DENOMINATOR * feeRate;
            // if ref level is opened
            if (refLevels[parentRefLevelIndex].refLevels >= feeLevel + 1) {
                // accrue interest to parent referrer
                EvxToken(rewardTokenAddress).distributeByReferralProgram(parentAddress, rewardAmount);
            } else {
                // accrue interest to treasury and burn addresses
                uint treasuryAmount = rewardAmount / DENOMINATOR * feeRateTreasury;
                uint burnAmount = rewardAmount / DENOMINATOR * feeRateBurn;
                EvxToken(rewardTokenAddress).distributeByReferralProgram(treasuryAddress, treasuryAmount);
                EvxToken(rewardTokenAddress).distributeByReferralProgram(burnAddress, burnAmount);
            }

            // set the next parent in the tree
            childAddress = parentAddress;
        }
    }

    //=================
	// Owner methods
	//=================

    /**
     * @notice Sets contract params
     * @param _rewardTokenAddress address of the reward token
     * @param _liquidityAddress address of the liquidity contract where user should send liquidity to open ref levels
     * @param _treasuryAddress treasury address where reward is sent when ref level is closed
     * @param _burnAddress burn address where reward is sent when ref level is closed
     * @param _feeRateTreasury % of reward sent to treasury address when ref level is closed, 100% = 1000000
     * @param _feeRateBurn % of reward sent to burn address when ref level is closed, 100% = 1000000
     */
    function setParams(
        address _rewardTokenAddress,
        address _liquidityAddress,
        address _treasuryAddress,
        address _burnAddress,
        uint _feeRateTreasury,
        uint _feeRateBurn
    ) 
        public
        onlyOwner
    {
        // validation
        require(_rewardTokenAddress != address(0), 'ZERO_ADDRESS');
        require(_liquidityAddress != address(0), 'ZERO_ADDRESS');
        require(_feeRateTreasury + _feeRateBurn == DENOMINATOR * 2, 'INVALID_FEE_RATES_SUM');
        // set variables
        liquidityAddress = _liquidityAddress;
        treasuryAddress = _treasuryAddress;
        burnAddress = _burnAddress;
        feeRateTreasury = _feeRateTreasury;
        feeRateBurn = _feeRateBurn;
    }

    /**
     * @notice Sets ref level
     * @param _refLevelIndex ref level index
     * @param _minLiquidityAmount min amount of liqudity needed to open a level
     * @param _refLevels number of levels from which user will get rewards
     * @param _swapFeeLevel swap fee levels
     * @param _stakingFeeLevel staking fee levels
     * @param _fixedStakingFeeLevel fixed staking fee levels
     * @param _yieldFarmingFeeLevel yield farming fee levels
     */
    function setRefLevel(
        uint _refLevelIndex,
        uint _minLiquidityAmount,
        uint _refLevels,
        FeeLevel memory _swapFeeLevel,
        FeeLevel memory _stakingFeeLevel,
        FeeLevel memory _fixedStakingFeeLevel,
        FeeLevel memory _yieldFarmingFeeLevel
    ) 
        public 
        onlyOwner 
    {
        // validation
        require(_refLevelIndex < REF_MAX_LEVEL_COUNT, 'LEVEL_NOT_EXIST');
        require(_refLevels >= 1 && _refLevels <= REF_MAX_SEARCH_LEVEL, 'INVALID_REF_LEVEL');
        // set ref level
        refLevels[_refLevelIndex].minLiquidityAmount = _minLiquidityAmount;
        refLevels[_refLevelIndex].refLevels = _refLevels;
        refLevels[_refLevelIndex].feeLevels[SourceRefContract.Swap] = _swapFeeLevel;
        refLevels[_refLevelIndex].feeLevels[SourceRefContract.Staking] = _stakingFeeLevel;
        refLevels[_refLevelIndex].feeLevels[SourceRefContract.FixedStaking] = _fixedStakingFeeLevel;
        refLevels[_refLevelIndex].feeLevels[SourceRefContract.YieldFarming] = _yieldFarmingFeeLevel;
    }

    /**
     * @notice Sets whitelist address which can accrue interest
     * @param _targetAddress address to whitelist
     * @param _isWhitelisted whether address is allowed to accrue interest
     */
    function setWhitelistAddress(
        address _targetAddress, 
        bool _isWhitelisted
    )
        public
        onlyOwner
    {
        whitelist[_targetAddress] = _isWhitelisted;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/**
 * @title Basic token for Evex DEX
 */
contract EvxToken is ERC20, Ownable {
    // address which stores tokens that should be burned
    address public burnAddress;

    // address of the treasury (used for staking rewards)
    address public treasuryAddress;

    // address of the YieldFarming contract which can mint EVX tokens for LP staking
    address public yieldFarmingAddress;

    // address of the Staking contract where users can stake DEX tokens
    address public stakingAddress;

    // address of the ReferralProgram contract
    address public referralProgramAddress;

    // initial token supply
    uint256 public initialSupply;

    // how many tokens were distributed for each token distribution target
    mapping (TokenDistributionTarget => uint256) public tokenDistributionTargetAmount;

    // capacity in % for each distribution target, ex: 100 = 1%
    mapping (TokenDistributionTarget => uint256) public tokenDistributionTargetCap;

    // whether token distribution target is set, can be set only once
    mapping (TokenDistributionTarget => bool) public tokenDistributionTargetIsSet;

    // Where tokens can be distributed (transfered)
    enum TokenDistributionTarget {
        IDO, // initial decentralized offering
        P2E, // play to earn
        TEAM, // team
        REFERRAL, // referral program
        LOCKED, // locked in the smart contract
        YIELD_FARMING, // yield farming
        STAKING, // staking
        MARKETING, // marketing and community
        SAFE_FUND // safe fund
    }

    /**
     * Contract constructor
     * @param _initialSupply initial token supply in wei
     * @param _tokenFullName token full name
     * @param _tokenTicker token ticker name
     * @param _burnAddress address where tokens to be burned should be stored
     * @param _yieldFarmingAddress address of the yield farming contract
     * @param _treasuryAddress address of treasury
     * @param _stakingAddress address of the staking contract
     * @param _referralProgramAddress address of the referral program contract
     */
    constructor(
        uint256 _initialSupply,
        string memory _tokenFullName,
        string memory _tokenTicker,
        address _burnAddress,
        address _yieldFarmingAddress,
        address _treasuryAddress,
        address _stakingAddress,
        address _referralProgramAddress
    ) ERC20(_tokenFullName, _tokenTicker) {
        // validation
        require(_initialSupply > 0, 'EvxToken.constructor: initial supply can not be 0');
        // assign constructor variables
        initialSupply = _initialSupply * 10**decimals();
        burnAddress = _burnAddress;
        yieldFarmingAddress = _yieldFarmingAddress;
        treasuryAddress = _treasuryAddress;
        stakingAddress = _stakingAddress;
        referralProgramAddress = _referralProgramAddress;
        // mint initial supply to current contract address
        _mint(address(this), initialSupply);
    }

    //=================
    // Public methods
    //=================

    /**
     * @notice Checks whether owner can distribute tokens for the specified distribution target
     * Owner can distribute tokens for the following distribution targets:
     * - team
     * - locked amount of tokens
     * - marketing and community
     * - safe fund
     * @param _tokenDistributionTarget token distribution target
     * @return whether owner can distribute tokens for the specified target
     */
    function canBeDistributedByOwner(TokenDistributionTarget _tokenDistributionTarget) public pure returns (bool) {
        bool result = false;
        if (_tokenDistributionTarget == TokenDistributionTarget.TEAM ||
            _tokenDistributionTarget == TokenDistributionTarget.LOCKED ||
            _tokenDistributionTarget == TokenDistributionTarget.MARKETING ||
            _tokenDistributionTarget == TokenDistributionTarget.SAFE_FUND
        ) {
            result = true;
        }
        return result;
    }

    /**
     * @notice Returns max token amount for a specified distribution target which owner can spend
     * @param _tokenDistributionTarget for what purpose tokens are distributed
     * @return max token amount for distribution target which owner can spend
     */
    function getTokenDistributionTargetCapacityLimit(TokenDistributionTarget _tokenDistributionTarget) public view returns(uint256) {
        return (initialSupply / 10_000) * tokenDistributionTargetCap[_tokenDistributionTarget];
    }

    /**
     * @notice Returns current total supply of EVX token
     * @return Current total supply
     */
    function totalSupply () public view override returns (uint256) {
        return balanceOf(address(this));
    }

    //=================
    // Owner methods
    //=================

    /**
     * Send tokens from the burn address
     * @param _to address where tokens should be sent
     * @param _amount amount of tokens to send
     */
    function burnByOwner(address _to, uint256 _amount) public onlyOwner {
        // validation
        require(_amount <= balanceOf(burnAddress), 'EvxToken.burnByOwner: not enough tokens to burn');
        // allow owner to burn tokens
        _approve(burnAddress, owner(), balanceOf(burnAddress));
        // burn tokens
        transferFrom(burnAddress, _to, _amount);
    }

    /**
     * @notice Distributes tokens by owner
     * @param _to address where tokens should be distributed
     * @param _amount amount of tokens to be distributed
     * @param _tokenDistributionTarget for what purpose tokens are distributed
     */
    function distributeByOwner(address _to, uint256 _amount, TokenDistributionTarget _tokenDistributionTarget) public onlyOwner {
        // validation
        require(canBeDistributedByOwner(_tokenDistributionTarget), 'EvxToken.distributeByOwner(): owner can not distribute tokens for this target');
        // distribute tokens
        _distribute(_to, _amount, _tokenDistributionTarget);
    }

    /**
     * @notice Updates burn address
     * @param _newBurnAddress updated burn address
     */
    function updateBurnAddressByOwner(address _newBurnAddress) public onlyOwner {
        burnAddress = _newBurnAddress;
    }

    /**
     * @notice Sets token distribution target capacity. Can be set only once.
     * Ex: 100 = 1%
     * @param _tokenDistributionTarget token distribution target
     * @param _cap token capacity rate, 100 = 1%
     */
    function setTokenDistributionTargetCapacityByOwner(TokenDistributionTarget _tokenDistributionTarget, uint256 _cap) public onlyOwner {
        // validation
        require(!tokenDistributionTargetIsSet[_tokenDistributionTarget], 'EvxToken.setTokenDistributionTargetCapacityByOwner(): capacity already set for this target');
        require(
            tokenDistributionTargetCap[TokenDistributionTarget.IDO] + 
            tokenDistributionTargetCap[TokenDistributionTarget.P2E] + 
            tokenDistributionTargetCap[TokenDistributionTarget.TEAM] + 
            tokenDistributionTargetCap[TokenDistributionTarget.REFERRAL] + 
            tokenDistributionTargetCap[TokenDistributionTarget.LOCKED] +
            tokenDistributionTargetCap[TokenDistributionTarget.YIELD_FARMING] + 
            tokenDistributionTargetCap[TokenDistributionTarget.STAKING] +
            tokenDistributionTargetCap[TokenDistributionTarget.MARKETING] +
            tokenDistributionTargetCap[TokenDistributionTarget.SAFE_FUND] +
            _cap <= 10_000,
            'EvxToken.setTokenDistributionTargetCapacityByOwner(): total capacity should be <= 10000 (100%)'   
        );

        // set capacity
        tokenDistributionTargetCap[_tokenDistributionTarget] = _cap;
        tokenDistributionTargetIsSet[_tokenDistributionTarget] = true;

        // if owner is allowed to distribute tokens for the specified target
        if (canBeDistributedByOwner(_tokenDistributionTarget)) {
            // Add allowance from contract to owner.
            // Each new distribution target (where owner can spend tokends) adds a new allowance sum.
            uint256 newAllowance = allowance(address(this), owner()) + getTokenDistributionTargetCapacityLimit(_tokenDistributionTarget);
            _approve(address(this), owner(), newAllowance);
        }
    }

    //==================================
    // Yield farming contract methods
    //==================================

    /**
     * @notice Distributes tokens by yield farming contract
     * @param _to address where tokens should be distributed
     * @param _amount amount of tokens to be distributed
     */
    function distributeByYieldFarming(address _to, uint256 _amount) public {
        // validation
        require(msg.sender == yieldFarmingAddress, 'EvxToken.distributeByYieldFarming(): only yield farming contract can distribute tokens');
        // approve yield farming contract to distribute tokens
        _approve(address(this), yieldFarmingAddress, _amount);
        // distribute tokens
        _distribute(_to, _amount, TokenDistributionTarget.YIELD_FARMING);
    }

    //==================================
    // Staking contract methods
    //==================================

    /**
     * @notice Distributes tokens by staking contract
     * @param _to address where tokens should be distributed
     * @param _amount amount of tokens to be distributed
     */
    function distributeByStaking(address _to, uint256 _amount) public {
        // validation
        require(msg.sender == stakingAddress, 'EvxToken.distributeByStaking(): only staking contract can distribute tokens');
        // approve staking contract to distribute tokens
        _approve(address(this), stakingAddress, _amount);
        // distribute tokens
        _distribute(_to, _amount, TokenDistributionTarget.STAKING);
    }

    //==================================
    // Referral program contract methods
    //==================================

    /**
     * @notice Distributes tokens by referral program contract
     * @param _to address where tokens should be distributed
     * @param _amount amount of tokens to be distributed
     */
    function distributeByReferralProgram(address _to, uint256 _amount) public {
        // validation
        require(msg.sender == referralProgramAddress, 'EvxToken.distributeByReferralProgram(): only referral program contract can distribute tokens');
        // approve referral program contract to distribute tokens
        _approve(address(this), referralProgramAddress, _amount);
        // if referral capacity limit is not reached then distribute tokens
        uint tokenDistributionTargetCapacityLimit = getTokenDistributionTargetCapacityLimit(TokenDistributionTarget.REFERRAL);
        bool isCapacityReached = tokenDistributionTargetAmount[TokenDistributionTarget.REFERRAL] + _amount > tokenDistributionTargetCapacityLimit;
        if (!isCapacityReached) {
            _distribute(_to, _amount, TokenDistributionTarget.REFERRAL);
        }
    }

    //===================
    // Internal methods
    //===================

    /**
     * @notice Distributes tokens to address for a specified distribution target
     * @param _to address where tokens should be transfered
     * @param _amount amount of tokens to be tranfered
     * @param _tokenDistributionTarget token distribution target
     */
    function _distribute(address _to, uint256 _amount, TokenDistributionTarget _tokenDistributionTarget) internal {
        // validation
        require(_to != address(0), 'EvxToken._distribute(): _to can not be the zero address');
        require(_amount > 0, 'EvxToken._distribute(): _amount can not be 0');
        require(_amount <= balanceOf(address(this)), 'EvxToken._distribute(): contract does not have enough EVX tokens');
        uint tokenDistributionTargetCapacityLimit = getTokenDistributionTargetCapacityLimit(_tokenDistributionTarget);
        require(tokenDistributionTargetAmount[_tokenDistributionTarget] + _amount <= tokenDistributionTargetCapacityLimit, 'EvxToken._distribute(): capacity limit reached');
        // update distributed amount
        tokenDistributionTargetAmount[_tokenDistributionTarget] += _amount;
        // transfer tokens
        transferFrom(address(this), _to, _amount);
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
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
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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