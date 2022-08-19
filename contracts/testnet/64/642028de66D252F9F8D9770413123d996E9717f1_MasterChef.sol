pragma solidity >=0.6.0 <=0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/ISpynPool.sol";
import "./libs/ISpynReferral.sol";

// import "@nomiclabs/buidler/console.sol";

// MasterChef is the master of SPYN. He can make SPYN and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once SPYN is sufficiently
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
        // We do some fancy math here. Basically, any point in time, the amount of SPYNs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accSpynPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accSpynPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. SPYNs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that SPYNs distribution occurs.
        uint256 accSpynPerShare; // Accumulated SPYNs per share, times 1e12. See below.
        uint256 harvestInterval;  // Harvest interval in seconds
        uint256 extraHarvestInterval;
        uint256 lpLockUntil; // Lock LP until ...
        uint256 extraLockInterval;
    }

    // The mining pool
    ISpynPool public miningPool;

    // The mining pool
    ISpynPool public marketingPool;
    address public rewardToken;
    // SPYN tokens created per block.
    uint256 public spynPerBlock;
    // Bonus muliplier for early SPYN makers.
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
    // The block number when SPYN mining starts.
    uint256 public startBlock;
    // Total locked up rewards
    uint256 public totalLockedUpRewards;

    address public treasury;

    // SPYN referral contract address.
    ISpynReferral public spynReferral;
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
    event DepositReferralCommissionPaid(address indexed user, address indexed referrer, uint256 level, uint256 commissionAmount, uint256 pid);
    event RewardLockedUp(address indexed user, uint256 indexed pid, uint256 amountLockedUp);
    event RewardSent(address indexed user, uint256 indexed pid, uint256 amount);
    event BonusMultiplierUpdated(uint256 value);
    event BaseAllocPointUpdated(uint256 value);
    event VaultAdded(address indexed vault, bool isVault);
    event PoolUpdated(uint256 pid, uint256 allocPoint, uint256 harvestInterval, uint256 extraHarvestInterval);
    event PoolLockUpdated(uint256 pid, uint256 lockUntil, uint256 extraLockInterval);
    event HarvestIntervalUpdated(uint256 value);
    event ReferralUpdated(address referral);
    event HarvestReferralCommissionRatesUpdated(uint16[] value);
    event HarvestFeeUpdated(uint256 value);
    event DepositReferralCommissionRatesUpdated(uint16[] value);
    event DepositFeeUpdated(uint256 value);
    event TreasuryUpdated(address value);

    modifier validatePoolByPid(uint256 _pid) {
        require (_pid < poolInfo.length , "Pool does not exist") ;
        _;
    }

    constructor(
        uint256 _spynPerBlock,
        uint256 _startBlock,
        address _miningPool,
        address _marketingPool,
        address _treasury,
        address _rewardToken
    ) {
        require(_miningPool != address(0) && _marketingPool != address(0) && _treasury != address(0), "MasterChef: setting the zero address");
        miningPool = ISpynPool(_miningPool);
        marketingPool = ISpynPool(_marketingPool);
        spynPerBlock = _spynPerBlock;
        startBlock = _startBlock;
        treasury = _treasury;
        rewardToken = _rewardToken;

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

    function setTreasury(address _treasury) public onlyOwner {
        treasury = _treasury;
        emit TreasuryUpdated(_treasury);
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
            accSpynPerShare: 0,
            harvestInterval: harvestInterval,
            extraHarvestInterval: harvestInterval,
            lpLockUntil: _lpLockUntil,
            extraLockInterval: 0
        }));
    }

    // Update the given pool's SPYN allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint) public onlyOwner {
        set2(_pid, _allocPoint, harvestInterval);
    }

    // Update the give pool's SPYN allocation point with harvest interval
    function set2(uint256 _pid, uint256 _allocPoint, uint256 _harvestInterval) public onlyOwner {
        set3(_pid, _allocPoint, _harvestInterval, _harvestInterval);
    }

    // Update the give pool's SPYN allocation point with harvest interval
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

    // View function to see pending SPYNs on frontend.
    function pendingSpyn(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSpynPerShare = pool.accSpynPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 allocPoint = totalAllocPoint();
            uint256 spynReward = multiplier.mul(spynPerBlock).mul(pool.allocPoint).div(allocPoint);
            accSpynPerShare = accSpynPerShare.add(spynReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accSpynPerShare).div(1e12).sub(user.rewardDebt);
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

    // View function to see if user can harvest SPYNs.
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
        uint256 spynReward = multiplier.mul(spynPerBlock).mul(pool.allocPoint).div(allocPoint);
        pool.accSpynPerShare = pool.accSpynPerShare.add(spynReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for SPYN allocation.
    function deposit(uint256 _pid, uint256 _amount, address _referrer) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (_amount > 0 && address(spynReferral) != address(0) && _referrer != address(0) && _referrer != msg.sender) {
            spynReferral.recordReferral(msg.sender, _referrer);
        }
        payOrLockupPendingSpyn(_pid, _amount > 0);
        if (_amount > 0) {
            uint256 balanceBefore = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint256 balanceAfter = pool.lpToken.balanceOf(address(this));
            uint256 depositedAmount = balanceAfter.sub(balanceBefore);

            if (!vaults[msg.sender]) {
                // pay deposit fee
                uint256 depositFeeAmount = depositedAmount.mul(depositFee).div(10000);
                if (depositFeeAmount > 0) {
                    pool.lpToken.safeTransfer(treasury, depositFeeAmount);
                }
                uint256 referralFeeTaken = payDepositReferralCommission(msg.sender, depositedAmount, _pid);
                depositedAmount = depositedAmount.sub(depositFeeAmount).sub(referralFeeTaken);
            }

            user.amount = user.amount.add(depositedAmount);
        }
        user.rewardDebt = user.amount.mul(pool.accSpynPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }
    
    function harvest(uint256 _pid) public {
        require(canHarvest(_pid, msg.sender), "cannot harvest");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        payOrLockupPendingSpyn(_pid, false);
        user.rewardDebt = user.amount.mul(pool.accSpynPerShare).div(1e12);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        require(vaults[msg.sender] || block.timestamp > pool.lpLockUntil + extraLockIntervalFor(_pid, msg.sender), "LP locked");

        updatePool(_pid);
        payOrLockupPendingSpyn(_pid, false);
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accSpynPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardLockedUp = 0;
        user.nextHarvestUntil = 0;
    }

    // Pay or lockup pending SPYNs.
    function payOrLockupPendingSpyn(uint256 _pid, bool resetTimer) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (resetTimer || user.nextHarvestUntil == 0) {
            user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
        }

        uint256 pending = user.amount.mul(pool.accSpynPerShare).div(1e12).sub(user.rewardDebt);
        if (canHarvest(_pid, msg.sender)) {
            if (pending > 0 || user.rewardLockedUp > 0) {
                uint256 totalRewards = pending.add(user.rewardLockedUp);

                // reset lockup
                totalLockedUpRewards = totalLockedUpRewards.sub(user.rewardLockedUp);
                user.rewardLockedUp = 0;
                user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);

                uint256 totalRewardsToHarvest = totalRewards;

                uint256 finalHarvestAmount = totalRewardsToHarvest;
                if (!vaults[msg.sender]) {
                    // pay referral commision
                    uint256 referralFeeTaken = payHarvestReferralCommission(msg.sender, totalRewards);

                    // take harvest fee
                    uint256 harvestFeeTaken =  takeHarvestFee(totalRewardsToHarvest);
                    finalHarvestAmount = totalRewardsToHarvest.sub(referralFeeTaken).sub(harvestFeeTaken);
                }
                // send rewards
                bool success = miningPool.safeTransfer(msg.sender, finalHarvestAmount);
                require(success, "Failed to send rewards, the pool is out of tokens");
                emit RewardSent(msg.sender, _pid, finalHarvestAmount);
            }
        } else if (pending > 0) {
            user.rewardLockedUp = user.rewardLockedUp.add(pending);
            totalLockedUpRewards = totalLockedUpRewards.add(pending);
            emit RewardLockedUp(msg.sender, _pid, pending);
        }
    }

    // Withdraw SPYN tokens from SPYN Pool.
    function withdrawMiningPool(address _to, uint256 _amount) public onlyOwner {
        bool success = miningPool.safeTransfer(_to, _amount);
        require(success, "Failed to send tokens, the pool is out of tokens");
    }

    // Withdraw SPYN tokens from SPYN Pool.
    function withdrawMarketingPool(address _to, uint256 _amount) public onlyOwner {
        bool success = marketingPool.safeTransfer(_to, _amount);
        require(success, "Failed to send tokens, the pool is out of tokens");
    }

    // We don't have hidden pools to alter emission rate, update it directly instead.
    function updateEmissionRate(uint256 _spynPerBlock) public onlyOwner {
        require(_spynPerBlock <= 1000000000000, "set: invalid spynPerBlock");
        massUpdatePools();
        emit EmissionRateUpdated(msg.sender, spynPerBlock, _spynPerBlock);
        spynPerBlock = _spynPerBlock;
    }

    // Set default harvest interval for farming pools
    function setHarvestInterval(uint256 _harvestInterval) public onlyOwner {
        require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "set: invalid harvest interval");
        harvestInterval = _harvestInterval;

        emit HarvestIntervalUpdated(_harvestInterval);
    }

    // Update the SPYN referral contract address by the owner
    function setSpynReferral(ISpynReferral _spynReferral) public onlyOwner {
        require(address(_spynReferral) != address(0), "MasterChef: setting the zero address");
        spynReferral = _spynReferral;

        emit ReferralUpdated(address(_spynReferral));
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
    function payHarvestReferralCommission(address _user, uint256 _pending) internal returns(uint256 feeTaken) {
        if (address(spynReferral) != address(0)) {
            address[] memory referrersByLevel = spynReferral.getReferrersByLevel(_user, harvestReferralCommissionRates.length);

            uint256 commissionAmount;
            for (uint256 i = 0; i < harvestReferralCommissionRates.length; i ++) {
                commissionAmount = _pending.mul(harvestReferralCommissionRates[i]).div(10000);
                if (commissionAmount > 0 && referrersByLevel[i] != address(0)) {
                    feeTaken = feeTaken.add(commissionAmount);

                    bool success = marketingPool.safeTransfer(referrersByLevel[i], commissionAmount);
                    require(success, "Failed to send referral rewards, the pool is out of tokens");
                    spynReferral.recordReferralCommission(referrersByLevel[i], _user, commissionAmount, rewardToken, 0, i);
                    emit HarvestReferralCommissionPaid(_user, referrersByLevel[i], i + 1, commissionAmount);
                }
            }
        }
    }

    // Pay referral commission to the referrer who referred this user.
    function payDepositReferralCommission(address _user, uint256 _depositedAmount, uint256 _pid) internal returns (uint256 feeTaken) {
        if (address(spynReferral) != address(0)) {
            address[] memory referrersByLevel = spynReferral.getReferrersByLevel(_user, depositReferralCommissionRates.length);

            PoolInfo memory pool = poolInfo[_pid];

            uint256 commissionAmount;
            for (uint256 i = 0; i < depositReferralCommissionRates.length; i ++) {
                commissionAmount = _depositedAmount.mul(depositReferralCommissionRates[i]).div(10000);
                if (commissionAmount > 0 && referrersByLevel[i] != address(0)) {
                    feeTaken = feeTaken.add(commissionAmount);
                    pool.lpToken.safeTransfer(referrersByLevel[i], commissionAmount);
                    spynReferral.recordReferralCommission(referrersByLevel[i], _user, commissionAmount, address(pool.lpToken), 1, i);
                    emit DepositReferralCommissionPaid(_user, referrersByLevel[i], i + 1, commissionAmount, _pid);
                }
            }
        }
    }

    // Take harvest fee 2.5%. 1% LP, 1% farming pool, 0.05% marketing wallet
    // We don't mint new tokens, we take taxes instead.
    function takeHarvestFee(uint256 _pending) internal returns (uint256 feeAmount) {

        feeAmount = _pending.mul(harvestFee).div(10000);

        uint256 remaining = _pending > feeAmount ? _pending.sub(feeAmount) : 0;

        require(remaining > 0, "Too small amount to harvest");

        // send feeAmount to marketing wallet
        if (feeAmount > 0) {
            bool success = miningPool.safeTransfer(address(marketingPool), feeAmount);
            require(success, "Failed to take fee, the pool is out of tokens");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

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
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
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

pragma solidity ^0.8.0;

interface ISpynPool {
    function safeTransfer(address _to, uint256 _amount) external returns (bool);
}

pragma solidity ^0.8.0;

interface ISpynReferral {
    /**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Record referral commission.
     */
    function recordReferralCommission(
        address _referrer,
        address _referee,
        uint256 _commission,
        address _token,
        uint256 _type,
        uint256 _level
    ) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);

    /**
     * @dev Get the referrer addresses that referred the user by level.
     */
    function getReferrersByLevel(
        address _user,
        uint256 count
    ) external view returns (
        address[] memory referrersByLevel
    );
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