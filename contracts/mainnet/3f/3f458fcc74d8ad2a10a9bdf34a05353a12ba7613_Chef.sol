// SPDX-License-Identifier: MIT
import "./Refferal.sol";
import "./token.sol";
// Adding-Identifier: MIT


// MasterChef is the master of RUBT. He can create new RUBT and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once RUBT is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.

pragma solidity >=0.6.0 <0.8.0;

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

    constructor() internal {
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
// File: node_modules\@uniswap\v2-periphery\contracts\interfaces\IUniswapV2Router01.sol

contract Chef is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    struct DepositAmount {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 lockUntil;
    }

    // Info of each user.
    struct UserInfo {
        uint256 amount;
        DepositAmount[] investments;
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 rewardLockedUp; // Reward locked up.
        uint256 nextHarvestUntil; // When can the user harvest again.
        uint256 startInvestmentPosition; //The first position haven't withdrawed

        //
        // We do some fancy math here. Basically, any point in time, the amount of RUBTES
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accRUBTPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accRUBTPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken; // Address of LP token contract.
        uint256 totalAmount; // Total amount in pool
        uint256 lastRewardBlock; // Last block number that RUBT distribution occurs.
        uint256 accTokenPerShare; // Accumulated RUBT per share, times 1e12. See below.
        uint16 depositFeeBP; // Deposit fee in basis points
        uint256 harvestInterval; // Harvest interval in seconds
        uint256 lockingPeriod;
        uint256 fixedApr;
        uint256 directCommission; //commission pay direct for the Leader;
    }

    // The RUBT TOKEN!
    RUBT public rubtToken;
    // Dev address.
    address public devAddress;
    // Deposit Fee address
    address public feeAddress;
    //busdAddress
    address public busdAddress = 0x55d398326f99059fF775485246999027B3197955;
    // uint256 public RUBTPerBlock;
    // Bonus muliplier for early RUBT Holder.
    uint256 public constant BONUS_MULTIPLIER = 1;
    // Max harvest interval: 14 days.
    uint256 public constant MAXIMUM_HARVEST_INTERVAL = 14 days;
    // Min locking period for add TotalFund
    uint256 public lockingRequirement = 31560000;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when RUBT mining starts.
    uint256 public startBlock;
    // Total locked up rewards
    uint256 public totalLockedUpRewards;
    bool public emergencyLockingWithdrawEnable = false;
    // RUBT referral contract address.
    Referral public referralContract;
    uint256 public referDepth = 1;
    uint256[] public referralCommissionTier = [100];

    // variables for migrate
    uint256 constant BLOCKS_PER_YEAR = 10512000;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event EmissionRateUpdated(
        address indexed caller,
        uint256 previousAmount,
        uint256 newAmount
    );
    event ReferralCommissionPaid(
        address indexed user,
        address indexed referrer,
        uint256 commissionAmount
    );
    event RewardLockedUp(
        address indexed user,
        uint256 indexed pid,
        uint256 amountLockedUp
    );

    constructor(
        RUBT _rubtToken,
        uint256 _startBlock
    ) public {
        rubtToken = _rubtToken;
        startBlock = _startBlock;
        devAddress = msg.sender;
        feeAddress = msg.sender;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    //Modifier to prevent adding the pool with the same token - I don't know what could happen here.
    // mapping(IBEP20 => bool) public poolExistence;
    // modifier nonDuplicated(IBEP20 _lpToken) {
    //     require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
    //     _;
    // }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(
        IBEP20 _lpToken,
        uint16 _depositFeeBP,
        uint256 _harvestInterval,
        uint256 _lockingPeriod,
    	uint256 _fixedApr,
    	uint256 _directCommission,
        bool _withUpdate
    ) public onlyOwner {
        require(
            _depositFeeBP <= 10000,
            "add: invalid deposit fee basis points"
        );
        require(
            _harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "add: invalid harvest interval"
        );
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;

        //poolExistence[_lpToken] = true;
    
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                lastRewardBlock: lastRewardBlock,
                accTokenPerShare: 0,
                depositFeeBP: _depositFeeBP,
                harvestInterval: _harvestInterval,
                lockingPeriod: _lockingPeriod,
                fixedApr: _fixedApr,
                totalAmount: 0,
                directCommission: _directCommission
            })
        );
    }

    // Update the given pool's RUBT allocation point and deposit fee. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint16 _depositFeeBP,
        uint256 _harvestInterval,
    	uint256 _fixedApr,
    	uint256 _directCommission,
        bool _withUpdate
    ) public onlyOwner {
        require(
            _depositFeeBP <= 10000,
            "set: invalid deposit fee basis points"
        );
        require(
            _harvestInterval <= MAXIMUM_HARVEST_INTERVAL,
            "set: invalid harvest interval"
        );
        if (_withUpdate) {
            massUpdatePools();
        }
            
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].harvestInterval = _harvestInterval;
        poolInfo[_pid].fixedApr = _fixedApr;
        poolInfo[_pid].directCommission = _directCommission;
        updatePool(_pid);
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending RUBT on frontend.
    function pendingReward(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        if (block.number > pool.lastRewardBlock) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );   
            uint256 TokenReward = multiplier.mul(pool.fixedApr).mul(1e12).div(BLOCKS_PER_YEAR.mul(100));
            accTokenPerShare = accTokenPerShare.add(TokenReward);
        }
        uint256 pending = user.amount.mul(accTokenPerShare).div(1e12).sub(
            user.rewardDebt
        );
        return pending.add(user.rewardLockedUp);
    }

    // View function to see if user can harvest RUBT.
    function canHarvest(uint256 _pid, address _user)
        public
        view
        returns (bool)
    {
        UserInfo storage user = userInfo[_pid][_user];
        return block.timestamp >= user.nextHarvestUntil;
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
        if (pool.totalAmount == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        
        uint256 TokenReward = multiplier.mul(pool.fixedApr).mul(pool.totalAmount).mul(1e12).div(BLOCKS_PER_YEAR.mul(100));

            // rubtToken.mint(devAddress, TokenReward.div(1e12).div(10));
            // rubtToken.mint(address(this), TokenReward.div(1e12));

        pool.accTokenPerShare = pool.accTokenPerShare.add(
            TokenReward.div(pool.totalAmount)
        );
        
        pool.lastRewardBlock = block.number;
    }
    

    // Deposit LP tokens to MasterChef for RUBT allocation.
    function deposit(
        uint256 _pid,
        uint256 _amount,
        address _referrer
    ) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (
            address(referralContract) != address(0) &&
            _referrer != address(0) &&
            _referrer != msg.sender &&
            referralContract.getReferrer(msg.sender) == address(0)
        ) {
            referralContract.recordReferral(msg.sender, _referrer);
        }
        payOrLockupPendingToken(_pid);
        if (_amount > 0) {
             pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            if (address(referralContract) != address(0)) {
                (address referrer) = referralContract.referrers(msg.sender);
                if (referrer != address(0)) {
                    if(pool.lockingPeriod > 0 && !emergencyLockingWithdrawEnable) {
                        payDirectCommission(_pid,_amount,referrer);
                    }
                }
            }
            
            if(pool.lockingPeriod > 0){
                user.investments.push(DepositAmount({
                    amount: _amount,
                    lockUntil: block.timestamp.add(pool.lockingPeriod)
                }));
            }
            if (pool.depositFeeBP > 0) {
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                pool.lpToken.safeTransfer(feeAddress, depositFee);
                user.amount = user.amount.add(_amount).sub(depositFee);
                
                pool.totalAmount = pool.totalAmount.add(_amount).sub(depositFee);
            } else {
                user.amount = user.amount.add(_amount);
                
                pool.totalAmount = pool.totalAmount.add(_amount);
            }        
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }
    
    function payDirectCommission(uint256 _pid,uint256 _amount, address referrer) internal {
        PoolInfo storage pool = poolInfo[_pid];
        uint256 directCommissionAmount = _amount.mul(pool.directCommission).div(1e2);
        safeTokenTransfer(referrer,directCommissionAmount);
        referralContract.recordReferralCommission(referrer,directCommissionAmount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        require(user.amount >= _amount, "withdraw: not good");
        require(pool.lockingPeriod == 0, "withdraw: not good");

        updatePool(_pid);
        payOrLockupPendingToken(_pid);
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.totalAmount = pool.totalAmount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function withdrawInvestment(uint256 _pid) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(pool.lockingPeriod > 0, "withdraw: not good");

        updatePool(_pid);
        payOrLockupPendingToken(_pid);

        uint _startInvestmentPosition = 0;
        uint256 _totalWithdrawalAmount = 0;

        for(uint i=user.startInvestmentPosition; i<user.investments.length;i++){
            
            if(user.investments[i].amount > 0 && user.investments[i].lockUntil <= block.timestamp){
                _totalWithdrawalAmount = _totalWithdrawalAmount.add(user.investments[i].amount);
                user.investments[i].amount = 0;
                _startInvestmentPosition = i+1;
            } else {
                break;
            }
            
        }

        if(_startInvestmentPosition > user.startInvestmentPosition){
            user.startInvestmentPosition = _startInvestmentPosition;
        }
        if(_totalWithdrawalAmount > 0 && _totalWithdrawalAmount <= user.amount){
            user.amount = user.amount.sub(_totalWithdrawalAmount);
            pool.totalAmount = pool.totalAmount.sub(_totalWithdrawalAmount);
            pool.lpToken.safeTransfer(address(msg.sender), _totalWithdrawalAmount);
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _totalWithdrawalAmount);
    }

    function getFreeInvestmentAmount(uint256 _pid, address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_pid][_user];
        uint256 _total = 0;

        for(uint i=user.startInvestmentPosition; i<user.investments.length;i++){
            if(user.investments[i].amount > 0 && user.investments[i].lockUntil <= block.timestamp){
                _total = _total.add(user.investments[i].amount);
            } else {
                break;
            }
        }

        return _total;
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(pool.lockingPeriod == 0 || emergencyLockingWithdrawEnable, "withdraw: not good");
        uint256 amount = user.amount;
        user.amount = 0;
        pool.totalAmount = pool.totalAmount.sub(amount);
        user.rewardDebt = 0;
        user.rewardLockedUp = 0;
        user.nextHarvestUntil = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Pay or lockup pending RUBT.
    function payOrLockupPendingToken(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (user.nextHarvestUntil == 0) {
            user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
        }

        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(
            user.rewardDebt
        );
        if (canHarvest(_pid, msg.sender)) {
            if (pending > 0 || user.rewardLockedUp > 0) {
                uint256 totalRewards = pending.add(user.rewardLockedUp);

                // reset lockup
                totalLockedUpRewards = totalLockedUpRewards.sub(
                    user.rewardLockedUp
                );
                user.rewardLockedUp = 0;
                user.nextHarvestUntil = block.timestamp.add(
                    pool.harvestInterval
                );

                // send rewards
                safeTokenTransfer(msg.sender, totalRewards);
                payReferralCommission(msg.sender, totalRewards, 0);
            }
        } else if (pending > 0) {
            user.rewardLockedUp = user.rewardLockedUp.add(pending);
            totalLockedUpRewards = totalLockedUpRewards.add(pending);
            emit RewardLockedUp(msg.sender, _pid, pending);
        }
    }

    // Safe RUBT transfer function, just in case if rounding error causes pool to not have enough RUBT to pay.
    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBalance = rubtToken.balanceOf(address(this));
        if (_amount > tokenBalance) {
            rubtToken.transfer(_to, tokenBalance);
        } else {
            rubtToken.transfer(_to, _amount);
        }
    }

    function setReferDepth(uint256 _depth) public onlyOwner {
        referDepth = _depth;
    }
    function setReferralCommissionTier(uint256[] memory _referralCommissionTier) public onlyOwner {
        referralCommissionTier = _referralCommissionTier;
    }
    function setLockingRequirement(uint256 _lockingRequirement) public onlyOwner {
        lockingRequirement = _lockingRequirement;
    }
    // Update dev address by the previous dev.
    function setDevAddress(address _devAddress) public {
        require(msg.sender == devAddress, "setDevAddress: FORBIDDEN");
        require(_devAddress != address(0), "setDevAddress: ZERO");
        devAddress = _devAddress;
    }

    function setFeeAddress(address _feeAddress) public {
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        require(_feeAddress != address(0), "setFeeAddress: ZERO");
        feeAddress = _feeAddress;
    }
    

    // Update the RUBT referral contract address by the owner
    function setReferral(Referral _referralContract) public onlyOwner {
        referralContract = _referralContract;
    }
    //Update the EmergencyWithdrawEnable
    function setEmergencyWithdrawEnable(bool _emergencyWithdrawEnable) public onlyOwner {
        emergencyLockingWithdrawEnable = _emergencyWithdrawEnable;
    }
    
    function getReferralCommissionRate(uint256 depth) private view returns (uint256){
        return referralCommissionTier[depth];
    }

    // Pay referral commission to the referrer who referred this user.
    function payReferralCommission(
        address _user,
        uint256 _pending,
        uint256 depth
    ) internal {
        if (depth < referDepth) {
            if (address(referralContract) != address(0)) {
                address _referrer  = referralContract.getReferrer(_user);
                
                uint256 commissionAmount = _pending
                    .mul(getReferralCommissionRate(depth))
                    .div(10000);
    
                if (commissionAmount > 0 && _referrer!=address(0)) {
                    rubtToken.mint(commissionAmount,_referrer);
                    referralContract.recordReferralCommission(
                        _referrer,
                        commissionAmount
                    );
                    emit ReferralCommissionPaid(_user, _referrer, commissionAmount);
                        payReferralCommission(
                            _referrer,
                            _pending,
                            depth.add(1)
                        );
                    }
            }
        }
    }
    
}