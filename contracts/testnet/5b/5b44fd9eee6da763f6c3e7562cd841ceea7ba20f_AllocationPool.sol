//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";


contract AllocationPool is Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable{
    using SafeERC20 for IERC20;
    using SafeCastUpgradeable for uint256;

    uint64 private constant ACCUMULATED_MULTIPLIER = 1e12;

    uint64 public constant ALLOC_MAXIMUM_DELAY_DURATION = 35 days; // maximum 35 days delay


    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address) internal override onlyOwner{}

     function initialize(
        IERC20 _rewardToken,
        uint128 _rewardPerBlock,
        uint64 _startBlock
    ) public initializer {
        __Ownable_init();

        __AllocationPool_init(_rewardToken, _rewardPerBlock, _startBlock);
    }

    // Info of each user.
    struct AllocUserInfo {
        uint128 amount; // How many LP tokens the user has provided.
        uint128 rewardDebt; // Reward debt. See explanation below.
        uint128 pendingReward; // Reward but not harvest
        //
        //   pending reward = (user.amount * pool.accRewardPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accRewardPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }
    // Info of each pool.
    struct AllocPoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint128 lpSupply; // Total lp tokens deposited to this pool.
        uint64 allocPoint; // How many allocation points assigned to this pool. Rewards to distribute per block.
        uint64 lastRewardBlock; // Last block number that rewards distribution occurs.
        uint128 accRewardPerShare; // Accumulated rewards per share, times 1e12. See below.
        uint128 delayDuration; // The duration user need to wait when withdraw.
        uint128 distributedAmount; // the total reward amounts that users has claimed 
    }

    struct AllocPendingWithdrawal {
        uint128 amount;
        uint128 applicableAt;
    }

    // The reward token!
    IERC20 public allocRewardToken;
    // Total rewards for each block.
    uint128 public allocRewardPerBlock;
    // The reward distribution address
    address public allocRewardDistributor;
    // Allow emergency withdraw feature
    bool public allocAllowEmergencyWithdraw;

    // Info of each pool.
    AllocPoolInfo[] public allocPoolInfo;
    // A record status of LP pool.
    mapping(IERC20 => bool) public allocIsAdded;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => AllocUserInfo)) public allocUserInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint64 public totalAllocPoint;
    // The block number when rewards mining starts.
    uint64 public allocStartBlockNumber;
    // The block number when rewards mining ends.
    uint64 public allocEndBlockNumber;
    // Info of pending withdrawals.
    mapping(uint256 => mapping(address => AllocPendingWithdrawal))
        public allocPendingWithdrawals;
    // A record disabled LP pools
    mapping(uint256 => bool) public allocIsDisabledDeposit;

    mapping(address => bool) public tokenExisted;
    mapping(address => mapping(address => uint256)) public tokenToUserTotalReward; // u
    address[] public allTokens;

    // Allow emergency transfer feature
    mapping(address => bool) public allocAllowEmergencyTransfer;

    mapping(uint256 => uint256) public totalUserStakedPerPool;

    event AllocPoolCreated(
        uint256 indexed pid,
        address indexed token,
        uint256 allocPoint
    );
    event AllocDeposit(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event AllocWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event AllocPendingWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event AllocEmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event AllocRewardsHarvested(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    /**
     * @notice Initialize the contract, get called in the first time deploy
     * @param _rewardToken the reward token address
     * @param _rewardPerBlock the number of reward tokens that got unlocked each block
     * @param _startBlock the block number when farming start
     */
    function __AllocationPool_init(
        IERC20 _rewardToken,
        uint128 _rewardPerBlock,
        uint64 _startBlock
    ) public initializer {
        __Ownable_init();

        require(
            address(_rewardToken) != address(0),
            "AllocStakingPool: invalid reward token address"
        );
        allocRewardToken = _rewardToken;
        allocRewardPerBlock = _rewardPerBlock;
        allocStartBlockNumber = _startBlock;


        totalAllocPoint = 0;
    }

    /**
     * @notice Validate pool by pool ID
     * @param _pid id of the pool
     */
    modifier allocValidatePoolById(uint256 _pid) {
        require(
            _pid < allocPoolInfo.length,
            "AllocStakingPool: pool are not exist"
        );
        _;
    }

    /**
     * @notice Return total number of pools
     */
    function allocPoolLength() public view returns (uint256) {
        return allocPoolInfo.length;
    }

    /**
     * @notice Add a new lp to the pool. Can only be called by the owner.
     * @param _allocPoint the allocation point of the pool, used when calculating total reward the whole pool will receive each block
     * @param _lpToken the token which this pool will accept
     * @param _delayDuration the time user need to wait when withdraw
     */
    function allocAddPool(
        uint64 _allocPoint,
        IERC20 _lpToken,
        uint128 _delayDuration
    ) external onlyOwner {
        require(
            !allocIsAdded[_lpToken],
            "AllocStakingPool: pool already is added"
        );
        require(
            _delayDuration <= ALLOC_MAXIMUM_DELAY_DURATION,
            "AllocStakingPool: delay duration is too long"
        );
        allocMassUpdatePools();

        address lpTokenAddress = address(_lpToken);
        if(!tokenExisted[lpTokenAddress]){
            allTokens.push(lpTokenAddress);
            tokenExisted[lpTokenAddress] = true;
        }

        uint64 lastRewardBlock = block.number > allocStartBlockNumber
            ? block.number.toUint64()
            : allocStartBlockNumber;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        allocPoolInfo.push(
            AllocPoolInfo({
                lpToken: _lpToken,
                lpSupply: 0,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accRewardPerShare: 0,
                delayDuration: _delayDuration,
                distributedAmount: 0
            })
        );
        allocIsAdded[_lpToken] = true;
        emit AllocPoolCreated(
            allocPoolInfo.length - 1,
            address(_lpToken),
            _allocPoint
        );
    }

    /**
     * @notice Update the given pool's reward allocation point. Can only be called by the owner.
     * @param _pid id of the pool
     * @param _allocPoint the allocation point of the pool, used when calculating total reward the whole pool will receive each block
     * @param _delayDuration the time user need to wait when withdraw
     */
    function allocSetPool(
        uint256 _pid,
        uint64 _allocPoint,
        uint128 _delayDuration
    ) external onlyOwner allocValidatePoolById(_pid) {
        require(
            _delayDuration <= ALLOC_MAXIMUM_DELAY_DURATION,
            "AllocStakingPool: delay duration is too long"
        );
        allocMassUpdatePools();

        totalAllocPoint =
            totalAllocPoint -
            allocPoolInfo[_pid].allocPoint +
            _allocPoint;
        allocPoolInfo[_pid].allocPoint = _allocPoint;
        allocPoolInfo[_pid].delayDuration = _delayDuration;
    }

    /**
     * @notice Set the reward distributor. Can only be called by the owner.
     * @param _allocRewardDistributor the reward distributor
     */
    function allocSetRewardDistributor(address _allocRewardDistributor)
        external
        onlyOwner
    {
        require(
            _allocRewardDistributor != address(0),
            "AllocStakingPool: invalid reward distributor"
        );
        allocRewardDistributor = _allocRewardDistributor;
    }

    /**
     * @notice Set the end block number. Can only be called by the owner.
     */
    function allocSetEndBlock(uint64 _endBlockNumber) external onlyOwner {
        require(
            _endBlockNumber > block.number,
            "AllocStakingPool: invalid reward distributor"
        );
        allocEndBlockNumber = _endBlockNumber;
    }

    /**
     * @notice Return time multiplier over the given _from to _to block.
     * @param _from the number of starting block
     * @param _to the number of ending block
     */
    function allocTimeMultiplier(uint128 _from, uint128 _to)
        public
        view
        returns (uint128)
    {
        if (allocEndBlockNumber > 0 && _to > allocEndBlockNumber) {
            return
                allocEndBlockNumber > _from ? allocEndBlockNumber - _from : 0;
        }
        return _to - _from;
    }

    /**
     * @notice Update number of reward per block
     * @param _rewardPerBlock the number of reward tokens that got unlocked each block
     */
    function allocSetRewardPerBlock(uint128 _rewardPerBlock)
        external
        onlyOwner
    {
        allocMassUpdatePools();
        allocRewardPerBlock = _rewardPerBlock;
    }

    /**
     * @notice Update disabled status of a pool
     * @param _pid id of the pool
     * @param _shouldDisabled should disabled deposit or not
     */
    function allocSetDisabledPool(uint128 _pid, bool _shouldDisabled)
        external
        onlyOwner
        allocValidatePoolById(_pid)
    {
        allocIsDisabledDeposit[_pid] = _shouldDisabled;
    }

    /**
     * @notice View function to see pending rewards on frontend.
     * @param _pid id of the pool
     * @param _user the address of the user
     */
    function allocPendingReward(uint256 _pid, address _user)
        public
        view
        allocValidatePoolById(_pid)
        returns (uint128)
    {
        if (totalAllocPoint == 0){
            return 0;
        }

        AllocPoolInfo storage pool = allocPoolInfo[_pid];
        AllocUserInfo storage user = allocUserInfo[_pid][_user];
        uint128 accRewardPerShare = pool.accRewardPerShare;
        uint128 lpSupply = pool.lpSupply;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint128 multiplier = allocTimeMultiplier(
                pool.lastRewardBlock,
                block.number.toUint128()
            );
            
            uint128 poolReward = (multiplier *
                allocRewardPerBlock *
                pool.allocPoint) / totalAllocPoint;
            accRewardPerShare =
                accRewardPerShare +
                ((poolReward * ACCUMULATED_MULTIPLIER) / lpSupply);
        }

        return
            user.pendingReward +
            (((user.amount * accRewardPerShare) / ACCUMULATED_MULTIPLIER) -
                user.rewardDebt);
    }

    /**
     * @notice Update reward vairables for all pools. Be careful of gas spending!
     */
    function allocMassUpdatePools() public {
        uint256 length = allocPoolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            allocUpdatePool(pid);
        }
    }

    /**
     * @notice Update reward variables of the given pool to be up-to-date.
     * @param _pid id of the pool
     */
    function allocUpdatePool(uint256 _pid) public allocValidatePoolById(_pid) {
        AllocPoolInfo storage pool = allocPoolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpSupply;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number.toUint64();
            return;
        }

        if(totalAllocPoint == 0){
            return;
        }

        uint256 multiplier = allocTimeMultiplier(
            pool.lastRewardBlock,
            block.number.toUint128()
        );
        uint256 poolReward = (multiplier *
            allocRewardPerBlock *
            pool.allocPoint) / totalAllocPoint;
        pool.accRewardPerShare = (pool.accRewardPerShare +
            ((poolReward * ACCUMULATED_MULTIPLIER) / lpSupply)).toUint128();
        pool.lastRewardBlock = block.number.toUint64();
    }

    /**
     * @notice Deposit LP tokens to the farm for reward allocation.
     * @param _pid id of the pool
     * @param _amount amount to deposit
     */
    function allocDeposit(uint256 _pid, uint128 _amount)
        external
        allocValidatePoolById(_pid)
    {
        require(
            !allocIsDisabledDeposit[_pid],
            "AllocStakingPool: pool is disabled deposit"
        );

        AllocPoolInfo storage pool = allocPoolInfo[_pid];
        AllocUserInfo storage user = allocUserInfo[_pid][msg.sender];

        allocUpdatePool(_pid);
        uint128 pending = ((user.amount * pool.accRewardPerShare) /
            ACCUMULATED_MULTIPLIER) - user.rewardDebt;

        if (user.amount == 0){
            totalUserStakedPerPool[_pid] +=1;
        }


        user.pendingReward = user.pendingReward + pending;
        user.amount = user.amount + _amount;
        user.rewardDebt =
            (user.amount * pool.accRewardPerShare) /
            ACCUMULATED_MULTIPLIER;
        pool.lpSupply = pool.lpSupply + _amount;
        
        //update token to total reward
        tokenToUserTotalReward[address(pool.lpToken)][msg.sender] += _amount;

        _allocTransferFrom(pool.lpToken, msg.sender, address(this), _amount);

        emit AllocDeposit(msg.sender, _pid, _amount);
    }

    /**
     * @notice Withdraw LP tokens from Pool.
     * @param _pid id of the pool
     * @param _amount amount to withdraw
     * @param _harvestReward whether the user want to claim the rewards or not
     */
    function allocWithdraw(
        uint256 _pid,
        uint128 _amount,
        bool _harvestReward
    ) external allocValidatePoolById(_pid) {
        _allocWithdraw(_pid, _amount, _harvestReward);

        AllocPoolInfo storage pool = allocPoolInfo[_pid];

        if (pool.delayDuration == 0) {
            _allocTransfer(pool.lpToken, msg.sender, _amount);
            emit AllocWithdraw(msg.sender, _pid, _amount);
            return;
        }

        AllocPendingWithdrawal
            storage pendingWithdraw = allocPendingWithdrawals[_pid][msg.sender];
        pendingWithdraw.amount = pendingWithdraw.amount + _amount;
        pendingWithdraw.applicableAt =
            block.timestamp.toUint128() +
            pool.delayDuration;
        emit AllocWithdraw(msg.sender, _pid, _amount);
    }

    /**
     * @notice Claim pending withdrawal
     * @param _pid id of the pool
     */
    function allocClaimPendingWithdraw(uint256 _pid)
        external
        allocValidatePoolById(_pid)
    {
        AllocPoolInfo storage pool = allocPoolInfo[_pid];

        AllocPendingWithdrawal
            storage pendingWithdraw = allocPendingWithdrawals[_pid][msg.sender];
        uint256 amount = pendingWithdraw.amount;
        require(amount > 0, "AllocStakingPool: nothing is currently pending");
        require(
            pendingWithdraw.applicableAt <= block.timestamp,
            "AllocStakingPool: not released yet"
        );
        delete allocPendingWithdrawals[_pid][msg.sender];
        _allocTransfer(pool.lpToken, msg.sender, amount);
    }

    /**
     * @notice Update allowance for emergency withdraw
     * @param _shouldAllow should allow emergency withdraw or not
     */
    function allocSetAllowEmergencyWithdraw(bool _shouldAllow)
        external
        onlyOwner
    {
        allocAllowEmergencyWithdraw = _shouldAllow;
    }

    /**
     * @notice Withdraw without caring about rewards. EMERGENCY ONLY.
     * @param _pid id of the pool
     */
    function allocEmergencyWithdraw(uint256 _pid)
        external
        allocValidatePoolById(_pid)
    {
        require(
            allocAllowEmergencyWithdraw,
            "AllocStakingPool: emergency withdrawal is not allowed yet"
        );
        AllocPoolInfo storage pool = allocPoolInfo[_pid];
        AllocUserInfo storage user = allocUserInfo[_pid][msg.sender];
        uint128 amount = user.amount;
        user.amount = 0;
        totalUserStakedPerPool[_pid] -=1;

        user.rewardDebt = 0;
        pool.lpSupply = pool.lpSupply - amount;
        tokenToUserTotalReward[address(pool.lpToken)][msg.sender] -= amount;

        //pool.lpToken.safeTransfer(address(msg.sender), amount);
        _allocTransfer(pool.lpToken, msg.sender, amount);
        emit AllocEmergencyWithdraw(msg.sender, _pid, amount);
    }

    /**
     * @notice Compound rewards to reward pool
     * @param _rewardPoolId id of the reward pool
     */
    function allocCompoundReward(uint256 _rewardPoolId)
        external
        allocValidatePoolById(_rewardPoolId)
    {
        AllocPoolInfo storage pool = allocPoolInfo[_rewardPoolId];
        AllocUserInfo storage user = allocUserInfo[_rewardPoolId][msg.sender];
        require(
            pool.lpToken == allocRewardToken,
            "AllocStakingPool: invalid reward pool"
        );

        uint128 totalPending = allocPendingReward(_rewardPoolId, msg.sender);

        require(totalPending > 0, "AllocStakingPool: invalid reward amount");

        user.pendingReward = 0;
        //allocSafeRewardTransfer(address(this), totalPending);
        _allocTransferFrom(allocRewardToken, allocRewardDistributor, address(this), totalPending);

        //note recheck here
        pool.distributedAmount += totalPending;

        emit AllocRewardsHarvested(msg.sender, _rewardPoolId, totalPending);

        allocUpdatePool(_rewardPoolId);

        user.amount = user.amount + totalPending;
        user.rewardDebt =
            (user.amount * pool.accRewardPerShare) /
            ACCUMULATED_MULTIPLIER;
        pool.lpSupply = pool.lpSupply + totalPending;
        tokenToUserTotalReward[address(pool.lpToken)][msg.sender] += totalPending;


        emit AllocDeposit(msg.sender, _rewardPoolId, totalPending);
    }

    /**
     * @notice Harvest proceeds msg.sender
     * @param _pid id of the pool
     */
    function allocClaimReward(uint256 _pid)
        public
        allocValidatePoolById(_pid)
        returns (uint128)
    {
        allocUpdatePool(_pid);
        AllocPoolInfo storage pool = allocPoolInfo[_pid];
        AllocUserInfo storage user = allocUserInfo[_pid][msg.sender];
        uint128 totalPending = allocPendingReward(_pid, msg.sender);
     
        require(totalPending > 0, "allocClaimReward: no token to claim");

        user.pendingReward = 0;
        user.rewardDebt =
            (user.amount * pool.accRewardPerShare) /
            (ACCUMULATED_MULTIPLIER);
        
        //allocSafeRewardTransfer(msg.sender, totalPending);
        _allocTransferFrom(allocRewardToken, allocRewardDistributor, msg.sender, totalPending);
        pool.distributedAmount += totalPending;
        
        emit AllocRewardsHarvested(msg.sender, _pid, totalPending);
        return totalPending;
    }

    /**
     * @notice Harvest proceeds of all pools for msg.sender
     * @param _pids ids of the pools
     */
    function allocClaimAll(uint256[] memory _pids) external {
        uint256 length = _pids.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            allocClaimReward(pid);
        }
    }

    /**
     * @notice Withdraw LP tokens from Pool.
     * @param _pid id of the pool
     * @param _amount amount to withdraw
     * @param _harvestReward whether the user want to claim the rewards or not
     */
    function _allocWithdraw(
        uint256 _pid,
        uint128 _amount,
        bool _harvestReward
    ) internal {
        AllocPoolInfo storage pool = allocPoolInfo[_pid];
        AllocUserInfo storage user = allocUserInfo[_pid][msg.sender];
        require(user.amount >= _amount, "AllocStakingPool: invalid amount");
        if (_harvestReward || user.amount == _amount) {
            uint128 totalPending = allocPendingReward(_pid, msg.sender);
            if (totalPending > 0){
                allocClaimReward(_pid);
            }
        } else {
            allocUpdatePool(_pid);
            uint128 pending = ((user.amount * pool.accRewardPerShare) /
                ACCUMULATED_MULTIPLIER) - user.rewardDebt;
            if (pending > 0) {
                user.pendingReward = user.pendingReward + pending;
            }
        }
        
        user.amount -= _amount;
        if (user.amount == 0){
            totalUserStakedPerPool[_pid] -=1;
        }

        user.rewardDebt =
            (user.amount * pool.accRewardPerShare) /
            ACCUMULATED_MULTIPLIER;
        pool.lpSupply = pool.lpSupply - _amount;
        tokenToUserTotalReward[address(pool.lpToken)][msg.sender] -= _amount;
        
    }

    function _allocTransfer(IERC20 _token, address _to, uint256 _amount) internal {
        require(_token.balanceOf(address(this))>= _amount, "allocTransfer: transfer amount exceed balance");
        
        _token.safeTransfer(_to, _amount);
    }

    /**
     * @notice abc
     */
    function _allocTransferFrom(IERC20 _token, address _from, address _to, uint256 _amount) public{
        require(_token.balanceOf(_from) >= _amount, "allocTransferFrom: transfer amount exceed balance");
        require(_token.allowance(_from, address(this)) >= _amount, "allocTransferFrom: transfer amount exceed allowance");

        _token.safeTransferFrom(
            _from,
            _to,
            _amount
        );
    }

    /* ============================= EMERGENCY FUNCTION ======================= */
     /**
     * @notice Update allowance for emergency transfer
     * @param _user user's wallet address
     * @param _shouldAllow should allow emergency transfer or not
     */
    function allocSetAllowEmergencyTransfer(address _user, bool _shouldAllow)
        external
        onlyOwner
    {
        allocAllowEmergencyTransfer[_user] = _shouldAllow;
    }

    /**
     * @notice Withdraw and transfer to another wallet without caring about rewards. EMERGENCY ONLY. 
     * @param _pid id of the pool
     * @param _recipient recipient of the fund
     */
    function allocEmergencyTransfer(uint256 _pid, address _recipient)
        external
        allocValidatePoolById(_pid)
    {
        require(
            allocAllowEmergencyTransfer[msg.sender],
            "AllocStakingPool: emergency transfer is not allowed yet"
        );
        AllocPoolInfo storage pool = allocPoolInfo[_pid];
        AllocUserInfo storage user = allocUserInfo[_pid][msg.sender];
        uint128 amount = user.amount;
        user.amount = 0;
        totalUserStakedPerPool[_pid] -=1;

        user.rewardDebt = 0;
        pool.lpSupply = pool.lpSupply - amount;
        pool.lpToken.safeTransfer(_recipient, amount);
    }

    /* ==================== GET USER DATA =================== */

    /**
     * @notice Function for frontend query 
     */
    function getUserDataAlloc(uint128 pId_, address user_) external view returns(
        uint128, // tvl
        uint128, // user stake balance 
        uint128, // distributed amount 
        uint128, //current reward 
        uint128 //reward per block
    ){
        if (pId_ >= allocPoolLength()){
            return(
                0, 0, 0, 0, allocRewardPerBlock
            );
        }
        AllocPoolInfo memory pool = allocPoolInfo[pId_];
        AllocUserInfo memory user = allocUserInfo[pId_][user_];
   
        uint128 pending_reward = allocPendingReward(pId_, user_); 
    
        return (
            pool.lpSupply,
            user.amount,
            pool.distributedAmount,
            pending_reward,
            allocRewardPerBlock
        );
    }

    /**
     * @notice function for front end query 
     */
    function getUserTotalReward(address user_) external view returns(
        address[] memory, // tokens
        uint256[] memory // amounts
    ){
        uint256[] memory amounts = new uint256[](allTokens.length);
        for(uint128 i =0; i< allTokens.length; i++){
            amounts[i] = tokenToUserTotalReward[allTokens[i]][user_];
        }
        return (allTokens, amounts);
    }

    /**
     * @dev function: get total user staked for each pool in array of pool ids_
     */
    function getTotalUserStakePools(uint128[] memory pIds_) external view returns(
        uint256[] memory totalUsers
    ){
        totalUsers = new uint256[](pIds_.length);

        for(uint256 i=0; i< pIds_.length; i++){
            totalUsers[i] = totalUserStakedPerPool[pIds_[i]];
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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeCast.sol)

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCastUpgradeable {
    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits.
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
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
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered.
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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

    // /**
    //  * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
    //  * but performing a delegate call.
    //  *
    //  * _Available since v3.4._
    //  */
    // function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
    //     return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    // }

    // /**
    //  * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
    //  * but performing a delegate call.
    //  *
    //  * _Available since v3.4._
    //  */
    // function functionDelegateCall(
    //     address target,
    //     bytes memory data,
    //     string memory errorMessage
    // ) internal returns (bytes memory) {
    //     require(isContract(target), "Address: delegate call to non-contract");

    //     (bool success, bytes memory returndata) = target.delegatecall(data);
    //     return verifyCallResult(success, returndata, errorMessage);
    // }

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
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}