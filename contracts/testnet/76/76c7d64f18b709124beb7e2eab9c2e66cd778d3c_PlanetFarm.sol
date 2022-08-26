// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./Dependencies.sol";


interface IStrategy {
    // Total want tokens managed by stratfegy
    function wantLockedTotal() external view returns (uint256);
    // Sum of all shares of users
    function sharesTotal() external view returns (uint256);
    // Transfer want tokens gammaFarm -> strategy
    function deposit(uint256 _wantAmt) external returns (uint256);
    // Transfer want tokens strategy -> gammaFarm
    function withdraw(uint256 _wantAmt) external returns (uint256, uint256);
    function emergencyWithdraw(uint256 _wantAmt) external returns (uint256, uint256);

}

interface Reservoir {
    
    function farmV2DripRate() external view returns(uint);
    function drip() external;
    
}

interface GammaInfinityVault {

    function depositAuthorized(address userAddress,uint256 _amount) external;
    function balanceOf(address userAddress) external returns(uint);

} 

contract PlanetFarm is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeERC20 for IERC20;
    using Math for uint256;

    Reservoir public ReservoirAddress;

    // Info of each user.
    struct UserInfo {
        uint256 shares; // Number of shares that the user has in the pool.
        uint256 rewardDebt; // Reward adjustment that the user should not receive at the next distribution.
        uint256 factor; // Square root of user.shares*iGammaBalance. This decides the share of boosted rewards that the user receives.
    }

    struct PoolInfo {
        IERC20 want; // Address of the want/lp token.
        uint96 allocPoint; //  Number of allocation points assigned to this pool. It determines the share of GAMMA distributed to this pool in the farm.
        uint256 lastRewardBlock; // Block number at which the last GAMMA distribution occurred.
        uint256 accGAMMAPerShare; // Accumulated GAMMA per share, times 1e12.
        address strat; // Address of the strategy that will store or compound want tokens.
        uint256 accGAMMMAPerFactorPerShare; // Boosted GAMMA rewards to be provided to users per user factor
        uint256 gammaRewardBoostPercentage; // Portion of the total GAMMA rewards to be rewarded to user as boosted rewards
        uint256 totalFactor; // Total factor of the pool. This is the sum of the user factors of all the users in the pool.
    }

    address public GAMMA;
    address public gammaInfinityVaultAddress;

    address public burnAddress;

    uint256 public startBlock;
    uint256 public totalAllocPoint; // Total allocation points. Must be the sum of all allocation points in all pools.

    bool public isDrip;
    bool public autoStakeGamma;

    PoolInfo[] public poolInfo; // Info of each pool.
    PoolInfo[] public boostedPools;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo; // Info of each user that stakes tokens.
    mapping(address => uint256) public usersClaimableGamma;
    mapping(address => uint256[]) public usersPoolList;
    mapping(uint256 => mapping(address => bool)) public usersHasSharesInPool;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event ReservoirChanged(Reservoir, Reservoir);
    event isDripChanged(bool oldStatus,bool newStatus);
    event AutoStakeGamma(bool isStateGamma);
    event GammaInfinityVaultAddressChanged(address oldGammaInfinity, address newGammaInfinity);

    function initialize() public initializer(){

        __Ownable_init();
        __ReentrancyGuard_init();
        ReservoirAddress = Reservoir(0x7cF0E175908Fc6D7f51CE793271D5c0BD674660F);
        GAMMA = 0xb3Cb6d2f8f2FDe203a022201C81a96c167607F15;
        gammaInfinityVaultAddress = 0x6bD50dFb39699D2135D987734F4984cd59eD6b53;
        burnAddress = 0x000000000000000000000000000000000000dEaD;
        startBlock = 0;
        totalAllocPoint = 0; // Total allocation points. Must be the sum of all allocation points in all pools.
        isDrip = true;
        autoStakeGamma = true;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new token to the pool. Can only be called by the owner.
    function add(uint96 _allocPoint, IERC20 _want, address _strat, uint _gammaRewardBoostPercentage, bool _withUpdate) external onlyOwner{
        
        require(_gammaRewardBoostPercentage <= 10_000, "boost percentage exceeds limit");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        
        PoolInfo memory poolData = PoolInfo({
            want: _want,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accGAMMAPerShare: 0,
            strat: _strat,
            accGAMMMAPerFactorPerShare: 0, // user's GAMMA share per factor 
            gammaRewardBoostPercentage: _gammaRewardBoostPercentage, // percentage of total dripped that will go for boosted rewards
            totalFactor: 0
        });

        poolInfo.push(poolData);
        boostedPools.push(poolData);
    
    }

    // Updates the given pool's GAMMA allocation point and gammaRewardBoostPercentage. Can only be called by the owner.
    function set(uint256 _pid, uint96 _allocPoint, uint _gammaRewardBoostPercentage, bool _withUpdate) external onlyOwner{
        require(_gammaRewardBoostPercentage <= 10_000, "boost percentage exceeds limit");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = (totalAllocPoint - poolInfo[_pid].allocPoint) + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].gammaRewardBoostPercentage = _gammaRewardBoostPercentage;
    }

    /// @notice Removes pool from the boosted list
    /// @param _pid poolInfo pid that needs to be removed
    function deprecateBoostForPool(uint256 _pid) external onlyOwner {

        require(poolInfo[_pid].gammaRewardBoostPercentage == 0, "boostPercentage is not 0");
        
        PoolInfo storage poolData = poolInfo[_pid];    
        address stratAddress = poolData.strat;
        uint256 boostedLength = boostedPools.length;
        for(uint256 i = 0; i < boostedLength; ++i){
            if(boostedPools[i].strat == stratAddress){
                boostedPools[i] = boostedPools[boostedLength - 1];
                boostedPools.pop();
                break;
            }
        }

    }

    /// @notice Removes pool from users pool list 
    /// @param _pid poolInfo pid that needs to be removed
    /// @param _user user for which the pid is to be removed from the list
    function _removePoolFromUsersPoolList(uint256 _pid, address _user) internal {

        usersHasSharesInPool[_pid][_user] = false;
        uint256 userPoolListLength = usersPoolList[_user].length;
        for(uint256 i = 0; i < userPoolListLength; ++i){
            if(usersPoolList[_user][i] == _pid){
                usersPoolList[_user][i] = usersPoolList[_user][userPoolListLength - 1];
                usersPoolList[_user].pop();
                break;
            }
        }
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256){
        if(!isDrip){
            return 0;
        }
        return _to - _from;
    }
    
    function GAMMAPerBlock() public view returns (uint256){
        return ReservoirAddress.farmV2DripRate();
    }

    // View function to calculate pending GAMMA for one pool.
    function _pendingGAMMA(uint256 _pid, address _user) internal view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accGAMMAPerShare = pool.accGAMMAPerShare;
        uint256 accGAMMMAPerFactorPerShare = pool.accGAMMMAPerFactorPerShare;

        uint256 sharesTotal = IStrategy(pool.strat).sharesTotal();
        if (block.number > pool.lastRewardBlock && sharesTotal != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 GAMMAReward = (multiplier*GAMMAPerBlock()*pool.allocPoint)/totalAllocPoint;
            accGAMMAPerShare = accGAMMAPerShare + (GAMMAReward*1e12)*(10_000 - pool.gammaRewardBoostPercentage)/(sharesTotal*10_000);

            if(pool.gammaRewardBoostPercentage != 0 && pool.totalFactor != 0){
                accGAMMMAPerFactorPerShare = accGAMMMAPerFactorPerShare + (GAMMAReward*1e12*pool.gammaRewardBoostPercentage)/(pool.totalFactor*10_000);
            }
        }
        return (user.shares*accGAMMAPerShare + user.factor*pool.accGAMMMAPerFactorPerShare)/1e12 - user.rewardDebt;
    }

    // View function to see pending GAMMA on frontend for all pools.
    function pendingGAMMAAllPools(address _user) external view returns (uint256) {
        uint poolLen = usersPoolList[_user].length;
        uint totalPendingGamma;

        for(uint i = 0; i < poolLen; ++i){
           totalPendingGamma = totalPendingGamma + _pendingGAMMA(usersPoolList[_user][i], _user);
        }
        return totalPendingGamma + usersClaimableGamma[_user];
    }

    // View function to see staked Want tokens on frontend.
    function stakedWantTokens(uint256 _pid, address _user) external view returns (uint256){
        UserInfo memory user = userInfo[_pid][_user];

        (uint256 wantLockedTotal, uint256 sharesTotal) = _getShares(_pid);
        if (sharesTotal == 0) {
            return 0;
        }

        return user.shares*wantLockedTotal/sharesTotal;
    }

    /// @notice Returns wantLockedTotal and total shares of a pool in the strategy contract
    /// @param _pid poolInfo pid to fetch data for
    function _getShares(uint256 _pid) internal view returns (uint256, uint256){
        PoolInfo memory pool = poolInfo[_pid];
        return(IStrategy(pool.strat).wantLockedTotal(), IStrategy(pool.strat).sharesTotal());
    }
    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public{
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public{

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 sharesTotal = IStrategy(pool.strat).sharesTotal();
        if (sharesTotal == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        if (multiplier <= 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 GAMMAReward = multiplier*GAMMAPerBlock()*pool.allocPoint/totalAllocPoint;
        
        //Reserving gamma based on gammaRewardBoostRate to reward the gamma stakers only
        //So before 100% gamma went to everyone now updatePool function divides total gamma dripped
        //into two bags one for boosted rewards other for the normal rewards. 
        if(pool.totalFactor > 0){
            pool.accGAMMMAPerFactorPerShare = pool.accGAMMMAPerFactorPerShare + (GAMMAReward*1e12*pool.gammaRewardBoostPercentage)/(pool.totalFactor*10_000);
        }
        //Common gamma to distributed to everyone else
        pool.accGAMMAPerShare = pool.accGAMMAPerShare + (GAMMAReward*1e12*(10_000 - pool.gammaRewardBoostPercentage))/(sharesTotal*10_000);

        pool.lastRewardBlock = block.number;
    }

    function stakeGammaOnInfinityvault(address _caller, uint _gammaAmount) internal {
        IERC20(GAMMA).safeIncreaseAllowance(gammaInfinityVaultAddress, _gammaAmount);
        GammaInfinityVault(gammaInfinityVaultAddress).depositAuthorized(_caller, _gammaAmount);
    }

    // Want tokens moved from user -> GammaFarm (GAMMA allocation) -> Strategy
    function deposit(uint256 _pid, uint256 _wantAmt) public nonReentrant {
        updatePool(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        uint256 pending = (user.shares*pool.accGAMMAPerShare + user.factor*pool.accGAMMMAPerFactorPerShare)*1e12 - user.rewardDebt;
        if (pending > 0) {
            usersClaimableGamma[_msgSender()] = usersClaimableGamma[_msgSender()] + pending;
        }

        if (_wantAmt > 0) {

            uint256 balanceBefore = pool.want.balanceOf(address(this));
            pool.want.safeTransferFrom(address(_msgSender()), address(this),_wantAmt);
            uint256 receivedAmount = pool.want.balanceOf(address(this)) - balanceBefore;
            pool.want.safeIncreaseAllowance(pool.strat, receivedAmount);

            if(!usersHasSharesInPool[_pid][_msgSender()]){
                usersHasSharesInPool[_pid][_msgSender()] = true;
                usersPoolList[_msgSender()].push(_pid);
            }
    
            uint sharesAdded = IStrategy(pool.strat).deposit(receivedAmount);
           
            _updateUserAndPool(user, pool, sharesAdded, true);

        }
        emit Deposit(_msgSender(), _pid, _wantAmt);
    }

    /// @notice Return an user's factor
    /// @param amount The user's amount of liquidity
    /// @param iGAMMABalance The user's iGamma balance
    /// @return uint256 The user's factor
    function _getUserFactor(uint256 amount, uint256 iGAMMABalance) private pure returns (uint256) {
        return Math.sqrt(amount * iGAMMABalance);
    }

    /// @notice Updates user and pool infos
    /// @param _user The user that needs to be updated
    /// @param _pool The pool that needs to be updated
    /// @param _shares The amount that was deposited or withdrawn
    /// @param _isDeposit If the action of the user is a deposit
    function _updateUserAndPool(UserInfo storage _user, PoolInfo storage _pool, uint256 _shares, bool _isDeposit) private {
        uint256 oldShares = _user.shares;
        uint256 newShares = _isDeposit ? oldShares + _shares : oldShares - _shares;

        if (_shares != 0) {
            _user.shares = newShares;
        }

        uint256 oldFactor = _user.factor;
        uint256 newFactor = _getUserFactor(newShares, GammaInfinityVault(gammaInfinityVaultAddress).balanceOf(_msgSender()));

        if (oldFactor != newFactor) {
            _user.factor = newFactor;
            _pool.totalFactor = _pool.totalFactor - oldFactor + newFactor;
        }

        _user.rewardDebt = (newShares * _pool.accGAMMAPerShare + newFactor * _pool.accGAMMMAPerFactorPerShare)/1e12;
    
    }

    /// @notice Updates factor after after a iGamma token operation.
    /// This function needs to be called by the iGamma contract after
    /// every mint / burn.
    /// @param _user The users address we are updating
    /// @param _newiGammaBalance The new balance of the users iGamma
    function updateFactor(address _user, uint256 _newiGammaBalance) external {
        require(_msgSender() == address(gammaInfinityVaultAddress), "Farm: Caller not GammaInfinityVault");
        uint256 len = boostedPools.length;

        for (uint256 pid; pid < len; ++pid) {
            UserInfo storage user = userInfo[pid][_user];

            // Skip if user doesn't have any deposit in the pool
            uint256 shares = user.shares;
            if (shares == 0) {
                continue;
            }

            PoolInfo storage pool = boostedPools[pid];

            updatePool(pid);
            uint256 oldFactor = user.factor;
            (uint256 accGAMMAPerShare, uint256 accGAMMAPerFactorPerShare) = (pool.accGAMMAPerShare, pool.accGAMMMAPerFactorPerShare);
            usersClaimableGamma[_user] = usersClaimableGamma[_user] + (shares*accGAMMAPerShare + oldFactor*accGAMMAPerFactorPerShare)/1e12 - user.rewardDebt;


            // Update users iGamma Balance
            uint256 newFactor = _getUserFactor(shares, _newiGammaBalance);
            user.factor = newFactor;
            pool.totalFactor = pool.totalFactor - oldFactor + newFactor;

            user.rewardDebt = (shares*accGAMMAPerShare + newFactor*accGAMMAPerFactorPerShare)/1e12;

        }
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _wantAmt) public nonReentrant {
        updatePool(_pid);
    
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];


        (uint256 wantLockedTotal, uint256 sharesTotal) = _getShares(_pid);
        uint256 wantRemoved;

        require(user.shares > 0, "user.shares is 0");
        require(sharesTotal > 0, "sharesTotal is 0");

        // Withdraw pending Gamma
        uint256 pending = (user.shares*pool.accGAMMAPerShare + user.factor*pool.accGAMMMAPerFactorPerShare)*1e12 - user.rewardDebt;

        if (pending > 0) {
            usersClaimableGamma[_msgSender()] = usersClaimableGamma[_msgSender()] + pending;
        }

        // Withdraw want tokens
        uint256 amount = user.shares*wantLockedTotal/sharesTotal;
        if (_wantAmt > amount) {
            _wantAmt = amount;
        }
        if (_wantAmt > 0) {

            (uint sharesRemoved, uint wantSentToFarm) = IStrategy(pool.strat).withdraw(_wantAmt);

            if(user.shares == 0)
                _removePoolFromUsersPoolList(_pid, _msgSender());

            _updateUserAndPool(user, pool, sharesRemoved, false);
      
            pool.want.safeTransfer(address(_msgSender()), wantSentToFarm);
        }
        
        emit Withdraw(_msgSender(), _pid, wantRemoved);
    }

    function withdrawAll(uint256 _pid) public nonReentrant {
        withdraw(_pid, type(uint256).max);
    }

    function claimAllPoolsPendingGamma() external nonReentrant {

        uint256 length = usersPoolList[_msgSender()].length;
        
        for(uint256 i = 0; i < length; ++i) {
            uint256 pid = usersPoolList[_msgSender()][i];
            updatePool(pid);
            PoolInfo storage pool = poolInfo[pid];
            UserInfo storage user = userInfo[pid][_msgSender()];

            if(user.shares > 0){
                uint256 pending = (user.shares*pool.accGAMMAPerShare + user.factor*pool.accGAMMMAPerFactorPerShare)*1e12 - user.rewardDebt;
                usersClaimableGamma[_msgSender()] = usersClaimableGamma[_msgSender()] + pending;
                user.rewardDebt = (user.shares*pool.accGAMMAPerShare + user.factor*pool.accGAMMMAPerFactorPerShare)*1e12;
            }

        }

        uint256 totalPending = usersClaimableGamma[_msgSender()];

        if(totalPending > IERC20(GAMMA).balanceOf(address(this)))
            if(isDrip)
                ReservoirAddress.drip();

        if(totalPending > 0) {
            if(autoStakeGamma)
                stakeGammaOnInfinityvault(_msgSender(), totalPending);
            else
                safeGAMMATransfer(_msgSender(), totalPending);
        }
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        (uint256 wantLockedTotal, uint256 sharesTotal) = _getShares(_pid);
       
        uint256 amount = user.shares*wantLockedTotal/sharesTotal;
        
        IStrategy(pool.strat).emergencyWithdraw(amount); 

        uint256 wantBal = IERC20(pool.want).balanceOf(address(this));
        if (wantBal < amount) {
            amount = wantBal;
        }

        user.shares = 0;
        user.rewardDebt = 0;
        pool.totalFactor = pool.totalFactor - user.factor;    
        user.factor = 0;
    
        _removePoolFromUsersPoolList(_pid, _msgSender());

        pool.want.safeTransfer(address(_msgSender()), amount);

        emit EmergencyWithdraw(_msgSender(), _pid, amount);
    }

    // Safe GAMMA transfer function, just in case if rounding error causes pool to not have enough
    function safeGAMMATransfer(address _to, uint256 _GAMMAAmt) internal {
        uint256 GAMMABal = IERC20(GAMMA).balanceOf(address(this));
        if (_GAMMAAmt > GAMMABal) {
            IERC20(GAMMA).transfer(_to, GAMMABal);
        } else {
            IERC20(GAMMA).transfer(_to, _GAMMAAmt);
        }
    }

    function inCaseTokensGetStuck(address _token, uint256 _amount) external onlyOwner{
        require(_token != GAMMA, "!safe");
        IERC20(_token).safeTransfer(_msgSender(), _amount);
    }

    function setReservoir(Reservoir _reservoir) external onlyOwner {
        Reservoir oldReservoir = ReservoirAddress;
        ReservoirAddress = _reservoir;
        emit ReservoirChanged(oldReservoir, ReservoirAddress);
    }
    
    function changeIsDrip(bool _dripStatus, bool _withUpdate) external onlyOwner {
        
        bool oldStatus = isDrip;
        require(_dripStatus != isDrip,"same status given");
        if (_withUpdate)
            massUpdatePools();

        isDrip = _dripStatus;
    
        emit isDripChanged(oldStatus, _dripStatus);
        
    }

    function setAutoStakeGamma(bool _isAutoStakeGamma) external onlyOwner {
        autoStakeGamma = _isAutoStakeGamma;
        emit AutoStakeGamma(_isAutoStakeGamma);
    }

    function setGammaInfinityVault(address _newGammaInfinityVault) external onlyOwner {
        require(_newGammaInfinityVault != address(0));
        address oldGammaInfinityVaultAddress = gammaInfinityVaultAddress;
        gammaInfinityVaultAddress = _newGammaInfinityVault;
        emit GammaInfinityVaultAddressChanged(oldGammaInfinityVaultAddress, _newGammaInfinityVault);
    }


}