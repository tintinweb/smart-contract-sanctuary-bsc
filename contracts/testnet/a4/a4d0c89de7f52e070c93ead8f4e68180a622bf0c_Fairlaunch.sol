// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

import "./interfaces/IAlpacaWorker.sol";
import "./interfaces/IVaultRouter.sol";
import "./interfaces/IShareToken.sol";
import "./interfaces/IWorkerConfig.sol";


contract Fairlaunch is Ownable
{
    modifier onlyRouter{
        require(VaultRouter == _msgSender() || owner() == _msgSender(),
         "Ownable: caller is not the router");
        _;
    }
    
    

    using SafeMath for uint256;
    using SafeMath for int256;
    struct UserInfo {
        uint256 RewardDebt;
        uint256 Amount;
    }
    struct WorkerInfo {
        uint256 BaseBalance;
        uint256 LastRewardBlock;
        int256 LastRewardPnL; // Last block number that Rewards distribution occurs.
        uint256 AccRewardPerShare; // Accumulated Rewards per share, times 1e12. See below. 
        uint256 LastRewardTime;
        address Dev;
        address UtilityToken;
        
    }
    struct PoolInfo {
        uint256 LastRewardBlock;
        uint256 AccRewardPerShare; // Accumulated Rewards per share, times 1e12. See below. 
        uint256 LastRewardTime;
        address Dev;
        address StakeToken;
        uint256 StakeBalance;
        uint256 AllocPoint;
    }
    address public RewardToken;
    address public VaultRouter;
    address public Dev;
    
    WorkerInfo[] public Workers;
    mapping(uint256 => mapping(address => UserInfo)) public WorkerUsers;
    
    PoolInfo[] public Pools;
    mapping(uint256 => mapping(address => UserInfo)) public PoolUsers;

    uint256 public TotalAllocPoint = 0;
    uint256 public RewardRatio = 1200;
    uint256 public LastUpdateTime;
    uint256 private constant ACC_REWARD_PRECISION = 1e12;
    event UpdateSharpeLib(int256 rate, int256 time);
    event RewardDistribute(uint256 amount, bool isManager);
    event ManagerDiscount(int256 val);
    event WithdrawCashReserve(uint256 val);
    
    function SetTokens(address rewardToken, 
    address vaultRouter,address dev) public onlyOwner
    {
        RewardToken = rewardToken;
        VaultRouter = vaultRouter;
        Dev = dev;
    }
    function SetParams(uint256 rewardRatio) public onlyOwner
    {
        RewardRatio = rewardRatio;
    }
    function SetWorker(uint256 workerId, address utilityToken) public onlyOwner
    {
        Workers[workerId].UtilityToken = utilityToken;
    }
    function SetPool(uint256 poolId, address stakeToken, uint256 allocPoint) public onlyOwner{
        PoolInfo storage pool = Pools[poolId];
        
        if(pool.StakeToken!= stakeToken){
            pool.StakeToken = stakeToken;
            pool.StakeBalance = 0;
        }
        TotalAllocPoint = TotalAllocPoint.sub(pool.AllocPoint).add(allocPoint);
        pool.AllocPoint = allocPoint;
    }
    function AddWorker(address dev,address utilityToken) public onlyOwner {
        Workers.push(WorkerInfo({
            BaseBalance:0,
            LastRewardBlock:block.number,
            LastRewardTime: block.timestamp,
            LastRewardPnL:0,
            AccRewardPerShare:0,
            Dev:dev,
            UtilityToken: utilityToken
        }));
    }
    function RemoveWorker(uint256 workerId) public onlyOwner{
        delete Workers[workerId];
    }
    function AddPool(address dev, address stakeToken, uint256 allocPoint) public onlyOwner {
        Pools.push(PoolInfo({
            LastRewardBlock:block.number,
            LastRewardTime: block.timestamp,
            AccRewardPerShare:0,
            Dev:dev,
            StakeToken: stakeToken,
            StakeBalance:0,
            AllocPoint: allocPoint
        }));
        TotalAllocPoint = TotalAllocPoint + allocPoint;
    }
    function RemovePool(uint256 poolId) public onlyOwner{
        delete Pools[poolId];
    }
    function WorkerDeposit(uint256 amount, uint256 workerId, address from) public onlyRouter {
        WorkerInfo storage worker = Workers[workerId];
        UserInfo storage user = WorkerUsers[workerId][from];
        UpdateWorker(workerId);
        uint256 useramount = IShareToken(IVaultRouter(VaultRouter).ShareTokens(workerId)).balanceOf(from);
        if (user.Amount > 0) {
            ClaimUtility(workerId, from);
        }
        useramount = useramount.add(amount);
        user.RewardDebt = useramount.mul(worker.AccRewardPerShare).div(ACC_REWARD_PRECISION);
    }
    function WorkerDeposit_Test(uint256 amount, uint256 workerId, address from, uint256 time, uint256 blockNo) public onlyRouter {
        WorkerInfo storage worker = Workers[workerId];
        UserInfo storage user = WorkerUsers[workerId][from];
        UpdateWorker_Test(workerId, time, blockNo);
        uint256 useramount = IShareToken(IVaultRouter(VaultRouter).ShareTokens(workerId)).balanceOf(from);
        if (user.Amount > 0) {
            ClaimUtility(workerId, from);
        }
        useramount = useramount.add(amount);
        user.RewardDebt = useramount.mul(worker.AccRewardPerShare).div(ACC_REWARD_PRECISION);
    }
    function WorkerWithdraw(uint256 amount, uint256 workerId, address to) public onlyRouter {
        WorkerInfo storage worker = Workers[workerId];
        UserInfo storage user = WorkerUsers[workerId][to];
        UpdateWorker(workerId);
        ClaimUtility(workerId, to);
        uint256 useramount = IShareToken(IVaultRouter(VaultRouter).ShareTokens(workerId)).balanceOf(to);
        useramount = useramount.sub(amount);
        user.RewardDebt = useramount.mul(worker.AccRewardPerShare).div(ACC_REWARD_PRECISION);
        // if (user.amount == 0) user.fundedBy = address(0);
        // if (pool.stakeToken != address(0)) {
        //   IERC20(pool.stakeToken).safeTransfer(address(msg.sender), _amount);
        // }
        // emit Withdraw(msg.sender, _pid, user.amount);
        
    }
    function WorkerWithdraw_Test(uint256 amount, uint256 workerId, address to, uint256 time, uint256 blockNo) public onlyRouter {
        WorkerInfo storage worker = Workers[workerId];
        UserInfo storage user = WorkerUsers[workerId][to];
        UpdateWorker_Test(workerId, time, blockNo);
        ClaimUtility(workerId, to);
        uint256 useramount = IShareToken(IVaultRouter(VaultRouter).ShareTokens(workerId)).balanceOf(to);
        useramount = useramount.sub(amount);
        user.RewardDebt = useramount.mul(worker.AccRewardPerShare).div(ACC_REWARD_PRECISION);
        // if (user.amount == 0) user.fundedBy = address(0);
        // if (pool.stakeToken != address(0)) {
        //   IERC20(pool.stakeToken).safeTransfer(address(msg.sender), _amount);
        // }
        // emit Withdraw(msg.sender, _pid, user.amount);
        
    }
    function ChangeShareToken_Test(uint256 workerId, uint256 amount, bool isMint)public
    {
        if(isMint)
        {
            IShareToken(IVaultRouter(VaultRouter).ShareTokens(workerId)).mint(owner(), amount);
        }
        else
        {
            IShareToken(IVaultRouter(VaultRouter).ShareTokens(workerId)).burn(owner(), amount);
        }
    }
    function Deposit(uint256 amount, uint256 poolId) public {
        PoolInfo storage pool = Pools[poolId];
        UserInfo storage user = PoolUsers[poolId][msg.sender];
        UpdatePool(poolId);
        if (user.Amount > 0) {
            uint256 pending = user.Amount.mul(pool.AccRewardPerShare).div(ACC_REWARD_PRECISION).sub(user.RewardDebt);
            if(pending > 0) {
                TransferHelper.safeTransfer(RewardToken, _msgSender(), amount);
            }
        }
        if (amount > 0) {
            TransferHelper.safeTransferFrom(pool.StakeToken,
             _msgSender(), address(this), amount);
            user.Amount = user.Amount.add(amount);
            pool.StakeBalance = pool.StakeBalance.add(amount);
        }
        user.RewardDebt = user.Amount.mul(pool.AccRewardPerShare).div(ACC_REWARD_PRECISION);
        
    }
    function Withdraw(uint256 amount, uint256 poolId) public 
    {
        PoolInfo storage pool = Pools[poolId];
        UserInfo storage user = PoolUsers[poolId][msg.sender];
        require(user.Amount >= amount, "withdraw: not good");

        UpdatePool(poolId);
        uint256 pending = user.Amount.mul(pool.AccRewardPerShare).div(ACC_REWARD_PRECISION).sub(user.RewardDebt);
        if(pending > 0) {
                TransferHelper.safeTransfer(RewardToken, _msgSender(), amount);
        }
        if (amount > 0) {
            TransferHelper.safeTransfer(pool.StakeToken, _msgSender(), amount);
            user.Amount = user.Amount.sub(amount);
            pool.StakeBalance = pool.StakeBalance.sub(amount);
        }
        user.RewardDebt = user.Amount.mul(pool.AccRewardPerShare).div(ACC_REWARD_PRECISION);
    }
    function Deposit_Test(uint256 amount, uint256 poolId,uint256 blockNumber, uint256 blockTime) public {
        PoolInfo storage pool = Pools[poolId];
        UserInfo storage user = PoolUsers[poolId][msg.sender];
        UpdatePool_Test(poolId, blockNumber, blockTime);
        if (user.Amount > 0) {
            uint256 pending = user.Amount.mul(pool.AccRewardPerShare).div(ACC_REWARD_PRECISION).sub(user.RewardDebt);
            if(pending > 0) {
                TransferHelper.safeTransfer(RewardToken, _msgSender(), amount);
            }
        }
        if (amount > 0) {
            TransferHelper.safeTransferFrom(pool.StakeToken,
             _msgSender(), address(this), amount);
            user.Amount = user.Amount.add(amount);
            pool.StakeBalance = pool.StakeBalance.add(amount);
        }
        user.RewardDebt = user.Amount.mul(pool.AccRewardPerShare).div(ACC_REWARD_PRECISION);
        
    }
    function Withdraw_Test(uint256 amount, uint256 poolId,uint256 blockNumber, uint256 blockTime) public 
    {
        PoolInfo storage pool = Pools[poolId];
        UserInfo storage user = PoolUsers[poolId][msg.sender];
        require(user.Amount >= amount, "withdraw: not good");

        UpdatePool_Test(poolId, blockNumber, blockTime);
        uint256 pending = user.Amount.mul(pool.AccRewardPerShare).div(ACC_REWARD_PRECISION).sub(user.RewardDebt);
        if(pending > 0) {
                TransferHelper.safeTransfer(RewardToken, _msgSender(), amount);
        }
        if (amount > 0) {
            TransferHelper.safeTransfer(pool.StakeToken, _msgSender(), amount);
            user.Amount = user.Amount.sub(amount);
            pool.StakeBalance = pool.StakeBalance.sub(amount);
        }
        user.RewardDebt = user.Amount.mul(pool.AccRewardPerShare).div(ACC_REWARD_PRECISION);
    }
    // Update reward variables for all pools. Be careful of gas spending!
    function UpdatePool(uint256 poolId) public
    {
        PoolInfo storage pool = Pools[poolId];
        if (block.number <= pool.LastRewardBlock) {
            return;
        }
        if (pool.StakeBalance == 0) {
            pool.LastRewardBlock = block.number;
            pool.LastRewardTime = block.timestamp;
            return;
        }

        uint256 reward = 
        pool.StakeBalance.mul(RewardRatio).mul(pool.AllocPoint).div(TotalAllocPoint).div(10000)
        .mul(block.timestamp - pool.LastRewardTime).div(365).div(86400);
        IShareToken(RewardToken).mint(address(this),reward);
        pool.AccRewardPerShare = pool.AccRewardPerShare.add(reward.mul(1e12).div(pool.StakeBalance));
        pool.LastRewardBlock = block.number;
        pool.LastRewardTime = block.timestamp;
    }
    function UpdatePool_Test(uint256 poolId,uint256 blockNumber, uint256 blockTime) public
    {
        PoolInfo storage pool = Pools[poolId];
        if ( blockNumber <= pool.LastRewardBlock) {
            return;
        }
        if (pool.StakeBalance == 0) {
            pool.LastRewardBlock =  blockNumber;
            pool.LastRewardTime = blockTime;
            return;
        }
        uint256 reward = 
        pool.StakeBalance.mul(RewardRatio).mul(pool.AllocPoint).div(TotalAllocPoint).div(10000)
        .mul(blockTime - pool.LastRewardTime).div(365).div(86400);
        IShareToken(RewardToken).mint(address(this),reward);
        pool.AccRewardPerShare = pool.AccRewardPerShare.add(reward.mul(ACC_REWARD_PRECISION).div(pool.StakeBalance));
        pool.LastRewardBlock =  blockNumber;
        pool.LastRewardTime = blockTime;
    }
    function UpdateWorker(uint256 workerId) public
    {
        WorkerInfo storage worker = Workers[workerId];
        IWorkerConfig config = IWorkerConfig(IVaultRouter(VaultRouter).WorkerConfigs(workerId));
        if (block.number <= worker.LastRewardBlock) {
            return;
        }
        address shareToken = IVaultRouter(VaultRouter).ShareTokens(workerId);
        address alpacaWorker = IVaultRouter(VaultRouter).Workers(workerId);
        uint256 sharesSupply = IShareToken(shareToken).totalSupply();
        if (sharesSupply == 0) {
            worker.LastRewardBlock = block.number;
            worker.LastRewardTime = block.timestamp;
            return;
        }
        uint256 totalVal = IAlpacaWorker(alpacaWorker).TotalVal();
        int256 curPnL = int256(totalVal) - int256(worker.BaseBalance) - worker.LastRewardPnL;
        
        {
            int256 curRate =  curPnL * 1e18 / (int256(worker.BaseBalance) + worker.LastRewardPnL);
            int256 period = int256(block.timestamp - worker.LastRewardTime);
            if(block.timestamp > worker.LastRewardTime){
                config.Add(curRate, period);
                emit UpdateSharpeLib(curRate, period);
            }
            
        }
        if(curPnL < 0)
        {
            uint256 reward = uint256(0 - curPnL) * 2 / 10;
            emit RewardDistribute(reward, false);
            worker.AccRewardPerShare = worker.AccRewardPerShare.add((reward.mul(ACC_REWARD_PRECISION).div(sharesSupply)));
            //IShareToken(worker.UtilityToken).mint(Dev, reward.div(10));
            IShareToken(worker.UtilityToken).mint(address(this), reward);
        }
        else
        {
            int256 mdf = config.ManagerDiscount()[0];
            uint256 reward = uint256(curPnL) * 2 * uint256(mdf) / 1e19 ;
            emit RewardDistribute(reward, true);
            emit ManagerDiscount(mdf);
            
            //IShareToken(worker.UtilityToken).mint(Dev, reward.div(10));
            IShareToken(worker.UtilityToken).mint(worker.Dev, reward);
            uint256 cashReserve = uint256(curPnL).mul(2).div(10);
            IVaultRouter(VaultRouter).SetasideBaseToken(cashReserve, workerId);
            curPnL = curPnL - int256(cashReserve);
            emit WithdrawCashReserve(cashReserve);
        }
        worker.LastRewardBlock = block.number;
        worker.LastRewardTime = block.timestamp;
        worker.LastRewardPnL = curPnL + worker.LastRewardPnL;
    }
    function UpdateWorker_Test(uint256 workerId,
    uint256 blockNumber, uint256 blockTime) public
    {
        WorkerInfo storage worker = Workers[workerId];
        IWorkerConfig config = IWorkerConfig(IVaultRouter(VaultRouter).WorkerConfigs(workerId));
        
        if (blockNumber <= worker.LastRewardBlock) {
            return;
        }
        address shareToken = IVaultRouter(VaultRouter).ShareTokens(workerId);
        address alpacaWorker = IVaultRouter(VaultRouter).Workers(workerId);
        uint256 sharesSupply = IShareToken(shareToken).totalSupply();
        if (sharesSupply == 0) {
            worker.LastRewardBlock = blockNumber;
            worker.LastRewardTime = blockTime;
            return;
        }
        uint256 totalVal = IAlpacaWorker(alpacaWorker).TotalVal();
        int256 curPnL = int256(totalVal) - int256(worker.BaseBalance) - worker.LastRewardPnL;
        
        {
            int256 curRate =  curPnL * 1e18 / (int256(worker.BaseBalance) + worker.LastRewardPnL);
            int256 period = int256(blockTime - worker.LastRewardTime);
            if(blockTime > worker.LastRewardTime){
                 config.Add(curRate, period);
                 emit UpdateSharpeLib(curRate, period);
            }
            
        }
        if(curPnL < 0)
        {
            uint256 reward = uint256(0 - curPnL) * 2 / 10;
            emit RewardDistribute(reward, false);
            worker.AccRewardPerShare = worker.AccRewardPerShare.add((reward.mul(ACC_REWARD_PRECISION).div(sharesSupply)));
            //IShareToken(worker.UtilityToken).mint(Dev, reward.div(10));
            IShareToken(worker.UtilityToken).mint(address(this), reward);
        }
        else
        {
            int256 mdf = config.ManagerDiscount()[0];
            uint256 reward = uint256(curPnL) * 2 * uint256(mdf) / 1e19 ;
            emit RewardDistribute(reward, true);
            emit ManagerDiscount(mdf);
            
            //IShareToken(worker.UtilityToken).mint(Dev, reward.div(10));
            IShareToken(worker.UtilityToken).mint(worker.Dev, reward);
            uint256 cashReserve = uint256(curPnL).mul(2).div(10);
            IVaultRouter(VaultRouter).SetasideBaseToken(cashReserve, workerId);
            curPnL = curPnL - int256(cashReserve);
            emit WithdrawCashReserve(cashReserve);
        }
        worker.LastRewardBlock = blockNumber;
        worker.LastRewardTime = blockTime;
        worker.LastRewardPnL = curPnL + worker.LastRewardPnL;
    }
    function UpdateWorkerInfo(uint256 amount, uint workerId, bool isDeposit) public onlyRouter 
    {
        if(isDeposit){
            Workers[workerId].BaseBalance = Workers[workerId].BaseBalance + amount;
            
        }
        else{
            Workers[workerId].BaseBalance = Workers[workerId].BaseBalance > amount ?
            Workers[workerId].BaseBalance - amount:
            0;
        }
        
    }
    function UpdatePoolInfo_Test(uint poolId,uint256 LastRewardTime,
    uint256 LastRewardBlock,uint256 AccRewardPerShare,uint256 StakeBalance) public {
        Pools[poolId].LastRewardBlock = LastRewardBlock;
        Pools[poolId].LastRewardTime = LastRewardTime;
        Pools[poolId].AccRewardPerShare = AccRewardPerShare;
        Pools[poolId].StakeBalance = StakeBalance;
    }
    function UpdateWorkerInfo_Test(uint256 BaseBalance,uint workerId, uint256 LastRewardTime,
    uint256 LastRewardBlock, int256 LastRewardPnL, uint256 AccRewardPerShare)
    public  onlyOwner {
        Workers[workerId].BaseBalance = BaseBalance;
        Workers[workerId].LastRewardTime = LastRewardTime;
        Workers[workerId].LastRewardBlock = LastRewardBlock;
        Workers[workerId].LastRewardPnL = LastRewardPnL;
        Workers[workerId].AccRewardPerShare = AccRewardPerShare;
    }
    function PendingReward(uint256 poolId) public view returns(uint256)
    {
        PoolInfo storage pool = Pools[poolId];
        UserInfo storage user = PoolUsers[poolId][_msgSender()];
        uint256 useramount = user.Amount;
        uint256 accumulatedAlpaca = useramount.mul(pool.AccRewardPerShare).div(ACC_REWARD_PRECISION);
        return accumulatedAlpaca.sub(user.RewardDebt);
    }
    function ClaimUtility(uint256 workerId, address to) public
    {
        WorkerInfo storage worker = Workers[workerId];
        UserInfo storage user = WorkerUsers[workerId][to];
        uint256 useramount = IShareToken(IVaultRouter(VaultRouter).ShareTokens(workerId)).balanceOf(to);
        uint256 accumulatedAlpaca = useramount.mul(worker.AccRewardPerShare).div(ACC_REWARD_PRECISION);
        uint256 _pendingReward = accumulatedAlpaca.sub(user.RewardDebt);
        if (_pendingReward == 0) {
            return;
        }
        require(_pendingReward <= IShareToken(worker.UtilityToken).balanceOf(address(this)), "FairLaunchV2::_harvest:: wtf not enough alpaca");
        // Effects
        user.RewardDebt = accumulatedAlpaca;

        // Interactions
        // ILocker _locker = lockers[pid];
        // if (address(_locker) != address(0)) {
        //   uint256 lockAmount = _locker.calLockAmount(_pendingReward);
        //   ALPACA.safeApprove(address(_locker), lockAmount);
        //   _locker.lock(to, lockAmount);
        //   _pendingReward = _pendingReward.sub(lockAmount);
        //   ALPACA.safeApprove(address(_locker), 0);
        // }
        TransferHelper.safeTransfer(worker.UtilityToken, to, _pendingReward);
    }
    function ClaimReward(uint256 poolId, address to) public {
        PoolInfo storage pool = Pools[poolId];
        UserInfo storage user = PoolUsers[poolId][to];
        uint256 useramount = user.Amount;
        uint256 accumulatedAlpaca = useramount.mul(pool.AccRewardPerShare).div(ACC_REWARD_PRECISION);
        uint256 _pendingReward = accumulatedAlpaca.sub(user.RewardDebt);
        if (_pendingReward == 0) {
            return;
        }
        require(_pendingReward <= IShareToken(RewardToken).balanceOf(address(this)), "FairLaunch::_harvest:: wtf not enough alpaca");
        // Effects
        user.RewardDebt = accumulatedAlpaca;

        // Interactions
        // ILocker _locker = lockers[pid];
        // if (address(_locker) != address(0)) {
        //   uint256 lockAmount = _locker.calLockAmount(_pendingReward);
        //   ALPACA.safeApprove(address(_locker), lockAmount);
        //   _locker.lock(to, lockAmount);
        //   _pendingReward = _pendingReward.sub(lockAmount);
        //   ALPACA.safeApprove(address(_locker), 0);
        // }
        TransferHelper.safeTransfer(RewardToken, to, _pendingReward);
    }
    function TransferRewardTokenOwnership(address newOwner) public onlyOwner{
        Ownable(RewardToken).transferOwnership(newOwner);
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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAlpacaWorker
{

    function ApproveToken(address token, address to, uint256 value) external;
    function ClosePosition(uint256 id, uint slippage) external returns (uint256);
    function ForcedClose(uint256 amount) external;
    function TotalVal() external view returns(uint256);
    function SetManagerAddress(address newManager) external;
    function BaseToken() external view returns(address);
    function ShareToken() external view returns(address);
    function manager() external view returns(address);
    function WithdrawToken(address token, address to,  uint256 value) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVaultRouter
{
    function Workers(uint256 workerId) external view returns(address);
    function ShareTokens(uint256 workerId) external view returns(address);
    function WorkerConfigs(uint256 workerId) external view returns(address);
    function Deposit(uint256 amount, uint256 workerId) external;
    function WithDraw(uint256 share, uint256 workerId) external;
    function ForcedWithdraw(uint256 share, uint256 workerId) external;
    function SetasideBaseToken(uint256 amount, uint256 workerId) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IShareToken {
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
    function transferFrom(
        address sender,
        address recipient,
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
  function mint(address account, uint256 amount) external;
  function burn(address account, uint256 amount) external;
  function UpdateShareVal(uint val) external;
  function ShareToAmount(uint256 share) external view returns (uint256);
  function AmountToShare(uint256 amount) external view returns (uint256);
  function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWorkerConfig
{
    struct WokerBase{
        address Worker;
        address ShareToken;
        address Config;

    }
    function ManagerDiscount() external view returns(int256[2] memory);
    function Add(int256 rate, int256 time)  external;
    function PendingManagementFee() external view returns(uint256);
    function PendingManagementFee_Test(uint256 time) external view returns(uint256);
    function SetLastFeeCollected(uint256 time) external;
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