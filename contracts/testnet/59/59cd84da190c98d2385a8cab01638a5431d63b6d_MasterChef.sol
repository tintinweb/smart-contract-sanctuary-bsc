/**
 * SPDX-License-Identifier: MIT
 */ 
pragma solidity ^0.8.4;

import "./Address.sol";
import "./Context.sol";
import "./IERC20.sol";
import "./IPAWLeaderboard.sol";
import "./IPAWPool.sol";
import "./IPAWReferral.sol";
import "./Ownable.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";


// import "@nomiclabs/buidler/console.sol";

// MasterChef is the master of PAW. He can make PAW and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once PAW is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 rewardLockedUp;  // Reward locked up.
        uint256 nextHarvestUntil; // When can the user harvest again.
        //
        // We do some fancy math here. Basically, any point in time, the amount of PAWs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accPAWPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accPAWPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. PAWs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that PAWs distribution occurs.
        uint256 accPAWPerShare; // Accumulated PAWs per share, times 1e12. See below.
        uint256 harvestInterval;  // Harvest interval in seconds
        uint256 extraHarvestInterval;
        uint256 lpLockUntil; // Lock LP until ...
        uint256 extraLockInterval;
    }

    // The mining pool
    IPAWPool public miningPool;

    address public rewardToken;
    // PAW tokens created per block.
    uint256 public PAWPerBlock;
    // Bonus muliplier for early PAW makers.
    uint256 public BONUS_MULTIPLIER = 1;


    uint256 public depositFee = 500;

    uint256 public harvestFee = 500;
    // harvest fee 10%

    uint256 public harvestInterval = 324 hours;
    // Max harvest interval: 14 days.
    uint256 public constant MAXIMUM_HARVEST_INTERVAL = 360 days;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // if address is a vault
    mapping (address => bool) public poolAddresses;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // if address is a vault
    mapping (address => bool) public vaults;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 internal totalAllocPoint_ = 0;
    // Base allocation points. we need this value to alter emission rate properly
    uint256 public baseAllocPoint = 0;
    // The block number when PAW mining starts.
    uint256 public startBlock;
    // Total locked up rewards
    uint256 public totalLockedUpRewards;
    address public treasury;
    address public feeTreasury;
    bool public lpStakeEnabled;

    // PAW referral contract address.
    IPAWReferral public PAWReferral;
    IPAWLeaderboard public PAWLeaderboard;
    // Referral commission rate in basis points.
    uint16[] public harvestReferralCommissionRates;
    uint16[] public depositReferralCommissionRates;
    // Max referral commission rate: 10%.
    uint16 public constant MAXIMUM_REFERRAL_COMMISSION_RATE = 1000;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmissionRateUpdated(address indexed caller, uint256 previousAmount, uint256 newAmount);
    event HarvestReferralCommissionPaid(address indexed user, address indexed referrer, uint256 level, uint256 commissionAmount);
    event HarvestReferralCommissionMissed(address indexed user, address indexed referrer, uint256 level, uint256 commissionAmount);
    event DepositReferralCommissionPaid(address indexed user, address indexed referrer, uint256 level, uint256 commissionAmount, uint256 pid);
    event DepositReferralCommissionMissed(address indexed user, address indexed referrer, uint256 level, uint256 commissionAmount, uint256 pid);
    event RewardLockedUp(address indexed user, uint256 indexed pid, uint256 amountLockedUp);
    event RewardSent(address indexed user, uint256 indexed pid, uint256 amount);
    event BonusMultiplierUpdated(uint256 value);
    event BaseAllocPointUpdated(uint256 value);
    event VaultAdded(address indexed vault, bool isVault);
    event PoolUpdated(uint256 pid, uint256 allocPoint, uint256 harvestInterval, uint256 extraHarvestInterval);
    event PoolLockUpdated(uint256 pid, uint256 lockUntil, uint256 extraLockInterval);
    event HarvestIntervalUpdated(uint256 value);
    event ReferralUpdated(address referral);
    event LeaderboardUpdated(address leaderboard);
    event HarvestReferralCommissionRatesUpdated(uint16[] value);
    event HarvestFeeUpdated(uint256 value);
    event DepositReferralCommissionRatesUpdated(uint16[] value);
    event DepositFeeUpdated(uint256 value);
    event TreasuryUpdated(address value);
    event FeeTreasuryUpdated(address value);

    modifier validatePoolByPid(uint256 _pid) {
        require (_pid < poolInfo.length , "Pool does not exist") ;
        _;
    }

    constructor(
        uint256 _PAWPerBlock,
        uint256 _startBlock,
        address _miningPool,
        address _treasury,
        address _feeTreasury,
        address _rewardToken
    ) {
        require(_miningPool != address(0) && _treasury != address(0) && _feeTreasury != address(0), "MasterChef: setting the zero address");
        miningPool = IPAWPool(_miningPool);
        PAWPerBlock = _PAWPerBlock;
        startBlock = _startBlock;
        treasury = _treasury;
        feeTreasury = _feeTreasury;
        
        rewardToken = _rewardToken;
        lpStakeEnabled = false;
        totalAllocPoint_ = 0;
        baseAllocPoint = 1000;

        harvestFee = 500;
        harvestReferralCommissionRates.push(100);
        harvestReferralCommissionRates.push(100);
        harvestReferralCommissionRates.push(100);
        harvestReferralCommissionRates.push(100);
        harvestReferralCommissionRates.push(100);

        depositFee = 500;
        depositReferralCommissionRates.push(500);
        depositReferralCommissionRates.push(400);
        depositReferralCommissionRates.push(300);
        depositReferralCommissionRates.push(200);
        depositReferralCommissionRates.push(100);
    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        require(multiplierNumber < 10, "bonus multiplier must be less than 10");
        BONUS_MULTIPLIER = multiplierNumber;
        emit BonusMultiplierUpdated(multiplierNumber);
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function setBaseAllocPoint(uint256 baseAllocPoint_) public onlyOwner {
        baseAllocPoint = baseAllocPoint_;
        emit BaseAllocPointUpdated(baseAllocPoint_);
    }

    function totalAllocPoint() public view returns (uint256) {
        return totalAllocPoint_.add(baseAllocPoint);
    }

    function setVault(address vault, bool isVault) public onlyOwner {
        vaults[vault] = isVault;
        emit VaultAdded(vault, isVault);
    }

    function setFeeTreasury(address _feeTreasury) public onlyOwner {
        feeTreasury = _feeTreasury;
        emit FeeTreasuryUpdated(_feeTreasury);
    }

    function setTreasury(address _treasury) public onlyOwner {
        treasury = _treasury;
        emit TreasuryUpdated(_treasury);
    }

    function setLPStakeEnabled(bool _lpStakeEnabled) public onlyOwner {
        lpStakeEnabled = _lpStakeEnabled;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, uint256 _lpLockUntil) public onlyOwner {
        require(!poolAddresses[address(_lpToken)], "the pool already exists");
        poolAddresses[address(_lpToken)] = true;

        massUpdatePools();
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint_ = totalAllocPoint_.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accPAWPerShare: 0,
            harvestInterval: harvestInterval,
            extraHarvestInterval: harvestInterval,
            lpLockUntil: _lpLockUntil,
            extraLockInterval: 0
        }));
    }

    // Update the given pool's PAW allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint) public onlyOwner {
        set2(_pid, _allocPoint, harvestInterval);
    }

    // Update the give pool's PAW allocation point with harvest interval
    function set2(uint256 _pid, uint256 _allocPoint, uint256 _harvestInterval) public onlyOwner {
        set3(_pid, _allocPoint, _harvestInterval, _harvestInterval);
    }

    // Update the give pool's PAW allocation point with harvest interval
    function set3(uint256 _pid, uint256 _allocPoint, uint256 _harvestInterval, uint256 _extraHarvestInterval) public onlyOwner validatePoolByPid(_pid) {
        require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "set: invalid harvest interval");
        massUpdatePools();
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].harvestInterval = _harvestInterval;
        poolInfo[_pid].extraHarvestInterval = _extraHarvestInterval;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint_ = totalAllocPoint_.sub(prevAllocPoint).add(_allocPoint);
        }

        emit PoolUpdated(_pid, _allocPoint, _harvestInterval, _extraHarvestInterval);
    }

    // Update the give pool's SPY allocation point with harvest interval
    function updateLpLockUntil(uint256 _pid, uint256 _lpLockUntil, uint256 _extraLockInterval) public onlyOwner validatePoolByPid(_pid) {
        require(_extraLockInterval < 365 days, "extra lock interval must be less than 1 year");
        poolInfo[_pid].lpLockUntil = _lpLockUntil;
        poolInfo[_pid].extraLockInterval = _extraLockInterval;
        emit PoolLockUpdated(_pid, _lpLockUntil, _extraLockInterval);
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending PAWs on frontend.
    function pendingPAW(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accPAWPerShare = pool.accPAWPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 allocPoint = totalAllocPoint();
            uint256 PAWReward = multiplier.mul(PAWPerBlock).mul(pool.allocPoint).div(allocPoint);
            accPAWPerShare = accPAWPerShare.add(PAWReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accPAWPerShare).div(1e12).sub(user.rewardDebt);
    }

    function extraHarvestIntervalFor(uint256 _pid, address _wallet) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        if (vaults[_wallet] || pool.extraHarvestInterval == 0) {
            return 0;
        }

        uint256 res = uint256(keccak256(abi.encodePacked(_wallet))) % pool.extraHarvestInterval;
        return res;
    }

    function extraLockIntervalFor(uint256 _pid, address _wallet) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        if (vaults[_wallet] || pool.extraLockInterval == 0) {
            return 0;
        }

        uint256 res = uint256(keccak256(abi.encodePacked(_wallet))) % pool.extraLockInterval;
        return res;
    }

    // View function to see if user can harvest PAWs.
    function canHarvest(uint256 _pid, address _user) public view returns (bool) {
        UserInfo storage user = userInfo[_pid][_user];
        uint256 extraHarvestInterval = extraHarvestIntervalFor(_pid, _user);
        return block.timestamp >= user.nextHarvestUntil + extraHarvestInterval;
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
        uint256 allocPoint = totalAllocPoint();
        uint256 PAWReward = multiplier.mul(PAWPerBlock).mul(pool.allocPoint).div(allocPoint);
        pool.accPAWPerShare = pool.accPAWPerShare.add(PAWReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for PAW allocation.
    function deposit(uint256 _pid, uint256 _amount, address _referrer) public {
        require(_pid == 0 || lpStakeEnabled || vaults[msg.sender], "LP staking is disabled");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (_amount > 0 && address(PAWReferral) != address(0) && _referrer != address(0) && _referrer != msg.sender) {
            PAWReferral.recordReferral(msg.sender, _referrer);
        }
        payOrLockupPendingPAW(_pid, _amount > 0);
        if (_amount > 0) {
            uint256 balanceBefore = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint256 balanceAfter = pool.lpToken.balanceOf(address(this));
            uint256 depositedAmount = balanceAfter.sub(balanceBefore);

            if (!vaults[msg.sender]) {
                // pay deposit fee
                uint256 feeTaken = takeDepositFee(msg.sender, depositedAmount, _pid);
                depositedAmount = depositedAmount.sub(feeTaken);

                if (address(PAWLeaderboard) != address(0)) {
                    PAWLeaderboard.recordStaking(msg.sender, address(pool.lpToken), depositedAmount);
                }
            }

            user.amount = user.amount.add(depositedAmount);
        }
        user.rewardDebt = user.amount.mul(pool.accPAWPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }
    
    function harvest(uint256 _pid) public {
        require(canHarvest(_pid, msg.sender), "cannot harvest");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        payOrLockupPendingPAW(_pid, false);
        user.rewardDebt = user.amount.mul(pool.accPAWPerShare).div(1e12);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        require(vaults[msg.sender] || block.timestamp > pool.lpLockUntil + extraLockIntervalFor(_pid, msg.sender), "LP locked");

        updatePool(_pid);
        payOrLockupPendingPAW(_pid, false);
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);

            if (!vaults[msg.sender]) {
                if (address(PAWLeaderboard) != address(0)) {
                    PAWLeaderboard.recordUnstaking(msg.sender, address(pool.lpToken), _amount);
                }
            }
        }
        user.rewardDebt = user.amount.mul(pool.accPAWPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);

        if (!vaults[msg.sender]) {
            if (address(PAWLeaderboard) != address(0)) {
                PAWLeaderboard.recordUnstaking(msg.sender, address(pool.lpToken), user.amount);
            }
        }
        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardLockedUp = 0;
        user.nextHarvestUntil = 0;
    }

    // Pay or lockup pending PAWs.
    function payOrLockupPendingPAW(uint256 _pid, bool resetTimer) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (resetTimer || user.nextHarvestUntil == 0) {
            user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
        }

        uint256 pending = user.amount.mul(pool.accPAWPerShare).div(1e12).sub(user.rewardDebt);
        if (canHarvest(_pid, msg.sender)) {
            if (pending > 0 || user.rewardLockedUp > 0) {
                uint256 totalRewards = pending.add(user.rewardLockedUp);

                // reset lockup
                totalLockedUpRewards = totalLockedUpRewards.sub(user.rewardLockedUp);
                user.rewardLockedUp = 0;
                user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);

                if (!vaults[msg.sender]) {
                    // pay referral commision
                    uint256 feeTaken = takeHarvestFee(msg.sender, totalRewards);
                    totalRewards = totalRewards.sub(feeTaken);
                }
                // send rewards
                bool success = miningPool.safeTransfer(msg.sender, totalRewards);
                require(success, "Failed to send rewards, the pool is out of tokens");
                emit RewardSent(msg.sender, _pid, totalRewards);
            }
        } else if (pending > 0) {
            user.rewardLockedUp = user.rewardLockedUp.add(pending);
            totalLockedUpRewards = totalLockedUpRewards.add(pending);
            emit RewardLockedUp(msg.sender, _pid, pending);
        }
    }

    // Withdraw PAW tokens from PAW Pool.
    function withdrawMiningPool(address _to, uint256 _amount) public onlyOwner {
        bool success = miningPool.safeTransfer(_to, _amount);
        require(success, "Failed to send tokens, the pool is out of tokens");
    }

    // We don't have hidden pools to alter emission rate, update it directly instead.
    function updateEmissionRate(uint256 _PAWPerBlock) public onlyOwner {
        require(_PAWPerBlock <= 1000000000000, "set: invalid PAWPerBlock");
        massUpdatePools();
        emit EmissionRateUpdated(msg.sender, PAWPerBlock, _PAWPerBlock);
        PAWPerBlock = _PAWPerBlock;
    }

    // Set default harvest interval for farming pools
    function setHarvestInterval(uint256 _harvestInterval) public onlyOwner {
        require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "set: invalid harvest interval");
        harvestInterval = _harvestInterval;

        emit HarvestIntervalUpdated(_harvestInterval);
    }

    // Update the PAW referral contract address by the owner
    function setPAWReferral(IPAWReferral _PAWReferral) public onlyOwner {
        require(address(_PAWReferral) != address(0), "MasterChef: setting the zero address");
        PAWReferral = _PAWReferral;

        emit ReferralUpdated(address(_PAWReferral));
    }

    // Update the PAW leaderboard contract address by the owner
    function setPAWLeaderboard(IPAWLeaderboard _PAWLeaderboard) public onlyOwner {
        require(address(_PAWLeaderboard) != address(0), "MasterChef: setting the zero address");
        PAWLeaderboard = _PAWLeaderboard;

        emit LeaderboardUpdated(address(_PAWLeaderboard));
    }

    function setHarvestReferralCommissionRates(uint16[] memory _referralCommissionRates) public onlyOwner {
        require(_referralCommissionRates.length <= 10, "referral depth is too deep");
        harvestReferralCommissionRates = _referralCommissionRates;

        emit HarvestReferralCommissionRatesUpdated(_referralCommissionRates);
    }

    function setHarvestFee(uint256 _harvestFee) public onlyOwner {
        require(_harvestFee <= 3000, "setHarvetFee: must be less than 3000 (30%) ");
        harvestFee = _harvestFee;

        emit HarvestFeeUpdated(_harvestFee);
    }

    function setDepositReferralCommissionRates(uint16[] memory _referralCommissionRates) public onlyOwner {
        require(_referralCommissionRates.length <= 10, "referral depth is too deep");
        depositReferralCommissionRates = _referralCommissionRates;

        emit DepositReferralCommissionRatesUpdated(_referralCommissionRates);
    }

    function setDepositFee(uint256 _depositFee) public onlyOwner {
        require(_depositFee <= 3000, "setHarvetFee: must be less than 3000 (30%) ");
        depositFee = _depositFee;

        emit DepositFeeUpdated(_depositFee);
    }

    // Pay referral commission to the referrer who referred this user.
    function takeHarvestFee(address _user, uint256 _pending) internal returns (uint256 feeTaken) {
        uint256 referralFeeMissing;
        uint256 referralFeeTaken;

        // take referral fee
        if (address(PAWReferral) != address(0)) {
            address[] memory referrersByLevel = PAWReferral.getReferrersByLevel(_user, harvestReferralCommissionRates.length);

            uint256 commissionAmount;
            for (uint256 i = 0; i < harvestReferralCommissionRates.length; i ++) {
                commissionAmount = _pending.mul(harvestReferralCommissionRates[i]).div(10000);
                if (commissionAmount > 0 && referrersByLevel[i] != address(0)) {
                    referralFeeTaken = referralFeeTaken.add(commissionAmount);
                    if (address(PAWLeaderboard) != address(0) && PAWLeaderboard.hasStaking(referrersByLevel[i])) {
                        bool success = miningPool.safeTransfer(referrersByLevel[i], commissionAmount);
                        require(success, "Failed to send referral rewards, the pool is out of tokens");
                        PAWReferral.recordReferralCommission(referrersByLevel[i], _user, commissionAmount, rewardToken, 0, i);
                        emit HarvestReferralCommissionPaid(_user, referrersByLevel[i], i + 1, commissionAmount);
                    } else {
                        bool success = miningPool.safeTransfer(treasury, commissionAmount);
                        require(success, "Failed to send referral rewards, the pool is out of tokens");
                        PAWReferral.recordReferralCommissionMissing(referrersByLevel[i], _user, commissionAmount, rewardToken, 0, i);
                        emit HarvestReferralCommissionMissed(_user, referrersByLevel[i], i + 1, commissionAmount);
                    }
                } else {
                    referralFeeMissing = referralFeeMissing.add(commissionAmount);
                }
            }
        } else {
            uint256 commissionAmount;
            for (uint256 i = 0; i < harvestReferralCommissionRates.length; i ++) {
                commissionAmount = _pending.mul(harvestReferralCommissionRates[i]).div(10000);
                referralFeeMissing = referralFeeMissing.add(commissionAmount);
            }
        }

        // take harvest fee
        uint256 harvestFeeAmount = _pending.mul(harvestFee).div(10000);
        harvestFeeAmount = harvestFeeAmount.add(referralFeeMissing);
        if (harvestFeeAmount > 0) {
            bool success = miningPool.safeTransfer(feeTreasury, harvestFeeAmount);
            require(success, "Failed to take fee, the pool is out of tokens");
        }

        feeTaken = harvestFeeAmount.add(referralFeeTaken);
    }

    function takeDepositFee(address _user, uint256 _depositedAmount, uint256 _pid) internal returns (uint256 feeTaken) {
        uint256 referralFeeMissing;
        uint256 referralFeeTaken;
        PoolInfo memory pool = poolInfo[_pid];
        if (address(PAWReferral) != address(0)) {
            address[] memory referrersByLevel = PAWReferral.getReferrersByLevel(_user, depositReferralCommissionRates.length);

            uint256 commissionAmount;
            for (uint256 i = 0; i < depositReferralCommissionRates.length; i ++) {
                commissionAmount = _depositedAmount.mul(depositReferralCommissionRates[i]).div(10000);
                if (commissionAmount > 0 && referrersByLevel[i] != address(0)) {
                    referralFeeTaken = referralFeeTaken.add(commissionAmount);
                    if (address(PAWLeaderboard) != address(0) && PAWLeaderboard.hasStaking(referrersByLevel[i])) {
                        pool.lpToken.safeTransfer(referrersByLevel[i], commissionAmount);
                        PAWReferral.recordReferralCommission(referrersByLevel[i], _user, commissionAmount, address(pool.lpToken), 1, i);
                        emit DepositReferralCommissionPaid(_user, referrersByLevel[i], i + 1, commissionAmount, _pid);
                    } else {
                        pool.lpToken.safeTransfer(treasury, commissionAmount);
                        PAWReferral.recordReferralCommissionMissing(referrersByLevel[i], _user, commissionAmount, address(pool.lpToken), 1, i);
                        emit DepositReferralCommissionMissed(_user, referrersByLevel[i], i + 1, commissionAmount, _pid);
                    }
                } else {
                    referralFeeMissing = referralFeeMissing.add(commissionAmount);
                }
            }
        } else {
            uint256 commissionAmount;
            for (uint256 i = 0; i < depositReferralCommissionRates.length; i ++) {
                commissionAmount = _depositedAmount.mul(depositReferralCommissionRates[i]).div(10000);
                referralFeeMissing = referralFeeMissing.add(commissionAmount);
            }
        }

        // pay deposit fee
        uint256 depositFeeAmount = _depositedAmount.mul(depositFee).div(10000);
        depositFeeAmount = depositFeeAmount.add(referralFeeMissing);
        if (depositFeeAmount > 0) {
            pool.lpToken.safeTransfer(feeTreasury, depositFeeAmount);
        }

        feeTaken = depositFeeAmount.add(referralFeeTaken);
    }
}