// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

// MasterChef is the master of TALLY. He can make TALLY and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once TALLY is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.



import './TallyToken.sol';

contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IERC20;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of TALLYs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accTALLYPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accTALLYPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }
    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. TALLYs to distribute per block.
        uint256 lastRewardBlock; // Last block number that TALLYs distribution occurs.
        uint256 accTALLYPerShare; // Accumulated TALLYs per share, times 1e12. See below.
        uint16 depositFeeBP;      // Deposit fee in basis points
        uint16 withdrawFeeBP;      // Deposit fee in basis points
    }
    // The TALLY TOKEN!
    TALLYToken public TALLY;
    //Pools, Farms, Dev, Refs percent decimals
    uint256 public percentDec = 1000000;
    //Pools and Farms percent from token per block 40%
    uint256 public stakingPercent = 400000;

    // Marketing Reserve address 0xFD69EB55Fed425b1694168206a41C332082f6bf1
    address public reservAddr = 0x660a63e4a491EfAb981a75d0B5dA1599f6461690;
    // Platform Maintenance & Security address 0x5cE77628d3E1c66c82f801c9dE0315E6d7F43D27
    address public platformMaintenanceSecurityAddr =
        0x7567a5Ad36D96afC4e0539FCf9b7A8c77849C6c2;
    // BUY BACK RESERVES address 0xF14F21f409859fcEa0193981016070FfEEBD4f7C
    address public buyBackReservesAddr =
        0x1429eC3815cdeAe70CAF23cf556e18302EDC6adD;
    // Operation Manager address 0x9eCa53cf9F2F540daADf9B1B890455bdc43f3804
    address public operationManagerAddr =
        0x1429eC3815cdeAe70CAF23cf556e18302EDC6adD;
    // Marketing Reserve percent 0.15%
    uint256 public reservPercent = 150000;
    // Platform Maintenance & Security percent 0.008%
    uint256 public maintenanceSecurityPercent = 8000;
    // BUY BACK RESERVES percent 0.1%
    uint256 public buyBackReservesPercent = 100000;
    // Operation Manager percent 0.142%
    uint256 public operationManagerPercent = 142000;

    // Last block then develeper withdraw dev and ref fee
    uint256 public lastBlockDevWithdraw;
    // TALLY tokens created per block.
    uint256 public TALLYPerBlock = 30000000000;
    // Bonus muliplier for early TALLY makers.
    uint256 public BONUS_MULTIPLIER = 1;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigratorChef public migrator;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when TALLY mining starts.
    uint256 public startBlock = 8626338;
    // Deposited amount TALLY in MasterChef
    uint256 public depositedTALLY;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(TALLYToken _TALLY) public {
        TALLY = _TALLY;

        // staking pool
        poolInfo.push(
            PoolInfo({
                lpToken: _TALLY,
                allocPoint: 1000,
                lastRewardBlock: startBlock,
                accTALLYPerShare: 0,
                depositFeeBP:0, // default fee 0
                withdrawFeeBP:0 // default fee 0
            })
        );

        totalAllocPoint = 1000;
        lastBlockDevWithdraw= block.number;
    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function withdrawDevAndRefFee() public {
        require(lastBlockDevWithdraw < block.number, "wait for new block");
        uint256 multiplier = getMultiplier(lastBlockDevWithdraw, block.number);
        uint256 TALLYReward = multiplier.mul(TALLYPerBlock);
        TALLY.transfer(reservAddr, TALLYReward.mul(reservPercent).div(percentDec));
        TALLY.transfer(
            platformMaintenanceSecurityAddr,
            TALLYReward.mul(buyBackReservesPercent).div(percentDec)
        );
        TALLY.transfer(
            buyBackReservesAddr,
            TALLYReward.mul(maintenanceSecurityPercent).div(percentDec)
        );
        TALLY.transfer(
            operationManagerAddr,
            TALLYReward.mul(operationManagerPercent).div(percentDec)
        );
        lastBlockDevWithdraw = block.number;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate,
        uint16 _depositFeeBP,
        uint16 _withdrawFeeBP
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accTALLYPerShare: 0,
                depositFeeBP:_depositFeeBP,
                withdrawFeeBP:_withdrawFeeBP
            })
        );
    }

    // Update the given pool's TALLY allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate,
        uint16 _depositFeeBP,
        uint16 _withdrawFeeBP
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].withdrawFeeBP = _withdrawFeeBP;
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }

    // Migrate lp token to another lp contract. Can be called by anyone. We trust that migrator contract is good.
    function migrate(uint256 _pid) public {
        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken);
        require(bal == newLpToken.balanceOf(address(this)), "migrate: bad");
        pool.lpToken = newLpToken;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending TALLYs on frontend.
    function pendingTALLY(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTALLYPerShare = pool.accTALLYPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (_pid == 0) {
            lpSupply = depositedTALLY;
        }
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(
                pool.lastRewardBlock,
                block.number
            );
            uint256 TALLYReward = multiplier
                .mul(TALLYPerBlock)
                .mul(pool.allocPoint)
                .div(totalAllocPoint)
                .mul(stakingPercent)
                .div(percentDec);
            accTALLYPerShare = accTALLYPerShare.add(
                TALLYReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accTALLYPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward vairables for all pools. Be careful of gas spending!
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
        if (_pid == 0) {
            lpSupply = depositedTALLY;
        }
        if (lpSupply <= 0) {
            pool.lastRewardBlock = block.number;
            return;
        }



        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 TALLYReward = multiplier
            .mul(TALLYPerBlock)
            .mul(pool.allocPoint)
            .div(totalAllocPoint)
            .mul(stakingPercent)
            .div(percentDec);
        //TALLY.mint(address(this), TALLYReward);
        pool.accTALLYPerShare = pool.accTALLYPerShare.add(
            TALLYReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MasterChef for TALLY allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        require(_pid != 0, "deposit TALLY by staking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accTALLYPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            safeTALLYTransfer(msg.sender, pending);
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        if (pool.depositFeeBP > 0) {
            uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
            pool.lpToken.safeTransfer(operationManagerAddr, depositFee);
            user.amount = user.amount.add(_amount).sub(depositFee);
        } else {

            user.amount = user.amount.add(_amount);
        }

        user.rewardDebt = user.amount.mul(pool.accTALLYPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        require(_pid != 0, "withdraw TALLY by unstaking");

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accTALLYPerShare).div(1e12).sub(
            user.rewardDebt
        );
        safeTALLYTransfer(msg.sender, pending);

        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accTALLYPerShare).div(1e12);
        if (pool.withdrawFeeBP>0){

            uint256 withdrawFee = _amount.mul(pool.withdrawFeeBP).div(10000);
            pool.lpToken.safeTransfer(operationManagerAddr, withdrawFee);
            uint256 transAmount = _amount.sub(withdrawFee);

            pool.lpToken.safeTransfer(address(msg.sender), transAmount);
        }else{

                 pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }

        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Stake TALLY tokens to MasterChef
    function enterStaking(uint256 _amount) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        updatePool(0);
        if (user.amount > 0) {
            uint256 pending = user
                .amount
                .mul(pool.accTALLYPerShare)
                .div(1e12)
                .sub(user.rewardDebt);
            if (pending > 0) {
                safeTALLYTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
            user.amount = user.amount.add(_amount);
            depositedTALLY = depositedTALLY.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accTALLYPerShare).div(1e12);
        emit Deposit(msg.sender, 0, _amount);
    }

    // Withdraw TALLY tokens from STAKING.
    function leaveStaking(uint256 _amount ) public {
        PoolInfo storage pool = poolInfo[0];
        UserInfo storage user = userInfo[0][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(0);
            uint pending = user.amount.mul(pool.accTALLYPerShare).div(1e12).sub(
            user.rewardDebt
        );

        if (pending > 0) {
            safeTALLYTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            depositedTALLY = depositedTALLY.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accTALLYPerShare).div(1e12);
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

    // Safe TALLY transfer function, just in case if rounding error causes pool to not have enough TALLYs.
    function safeTALLYTransfer(address _to, uint256 _amount) internal {
        uint256 TALLYBal = TALLY.balanceOf(address(this));
        if (_amount > TALLYBal) {
            TALLY.transfer(_to, TALLYBal);
        } else {
            TALLY.transfer(_to, _amount);
        }
    }

    function setReservAddress(address _reservAddr) public onlyOwner {
        reservAddr = _reservAddr;
    }

    function setBuyBackReservesAddress(address _buyBackReservesAddr)
        public
        onlyOwner
    {
        buyBackReservesAddr = _buyBackReservesAddr;
    }

    function setPlatformMaintenanceSecurityAddress(
        address _platformMaintenanceSecurityAddr
    ) public onlyOwner {
        platformMaintenanceSecurityAddr = _platformMaintenanceSecurityAddr;
    }

    function setOperationManagerAddress(address _operationManagerAddr)
        public
        onlyOwner
    {
        operationManagerAddr = _operationManagerAddr;
    }

    function updateTALLYPerBlock(uint256 newAmount) public onlyOwner {
        require(newAmount <= 30 * 1e9, "Max per block 30 TALLY");
        require(newAmount >= 1 * 1e9, "Min per block 1 TALLY");
        TALLYPerBlock = newAmount;
    }

    function setStakingPercent(uint256 _stakingPercent) public onlyOwner {
        stakingPercent = _stakingPercent;
    }

    function setReservPercent(uint256 _reservPercent) public onlyOwner {
        reservPercent = _reservPercent;
    }

    function setMaintenanceSecurityPercent(uint256 _maintenanceSecurityPercent)
        public
        onlyOwner
    {
        maintenanceSecurityPercent = _maintenanceSecurityPercent;
    }

    function setBuyBackReservesPercent(uint256 _buyBackReservesPercent)
        public
        onlyOwner
    {
        buyBackReservesPercent = _buyBackReservesPercent;
    }

    function setOperationManagerPercent(uint256 _operationManagerPercent)
        public
        onlyOwner
    {
        operationManagerPercent = _operationManagerPercent;
    }
}