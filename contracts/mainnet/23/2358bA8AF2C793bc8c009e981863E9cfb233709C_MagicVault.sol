// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./Farms.sol";

contract MagicVault is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;
    bool internal locked;

    address public treasury; //treasury account, where 3% of fees in BUSD will be diverted.
    address public burningVault; //burning vault, where 2% of fees in BUSD will be diverted.

    uint256 public treasuryFee = 300; //treasury fee. all txn will be assessed a 3% fee and diverted to treasury.
    uint256 public vaultFee = 200; //burning vault fee. all txn will be assessed a 2% fee and diverted to the vault.
    uint256 public depositFee = treasuryFee.add(vaultFee); //total deposit fee
    uint256 public performanceFee = 2500;

    uint256 public pid = 0; //the poolId. Initiated to 0.

    IERC20 public busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IERC20 public crystal = IERC20(0xa1A5AD28C250B9383c360c0f69aD57D70379851e);
    IERC20 public diamond = IERC20(0xcAE4F3977c084aB12B73a920e670e1665B3fA7D5);
    DIARewardPool public farms =
        DIARewardPool(0xb2C5A04A71426756FCAbD0439E3738373C0A5064);
    address public router;
    IUniswapV2Pair public pair;

    struct UserInfo {
        uint256 busdInvested; //amount busd invested, net of totalFees.
        uint256 crystalsAllotted; //amount of crystal provided to mint LPs.
        uint256 lpsPlanted; //amount of LPs net of fees.
        uint256 rewardDebt; //reward calculation from Farms
    }

    struct PoolInfo {
        IERC20 token; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. DIAs to distribute per block.
        uint256 lastRewardTime; // Last time that DIAs distribution occurs.
        uint256 accDIAPerShare; // Accumulated DIAs per share, times 1e18. See below.
        bool isStarted; // if lastRewardTime has passed
        uint256 depositFee; // deposit fee
        uint256 withdrawFee; // withdraw fee
    }

    PoolInfo public copiedPoolInfo;
    mapping(address => UserInfo) public userInfo;

    modifier noReentrant() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    event MagicDeposit(address indexed user, uint256 indexed pid, uint256 busdInvested, uint256 crystalsAllotted, uint256 lpsPlanted);
    event MagicWithdrawl(address indexed user, uint256 indexed pid, uint256 busdInvested, uint256 diaRewardSent);
    event CrystalsAdded(address indexed user, uint256 addedAmount);

    constructor(
        address _uniswapRouter,
        address _treasury,
        address _burningVault
    ) {
        router = _uniswapRouter;
        treasury = _treasury;
        burningVault = _burningVault;

        pair = IUniswapV2Pair(
            IUniswapV2Factory(IUniswapV2Router02(router).factory()).getPair(
                address(busd),
                address(crystal)
            )
        );
    }

    function fundVaultWithCrystals(uint256 amountToFund)
        public
        onlyOwner
        returns (uint256)
    {
        require(amountToFund > 0, "low funds to transfer");

        require(crystal.balanceOf(msg.sender) >= amountToFund, "low balance");

        require(
            amountToFund <= crystal.allowance(msg.sender, address(this)),
            "allowance"
        );

        crystal.safeTransferFrom(msg.sender, address(this), amountToFund);

        emit CrystalsAdded(msg.sender, amountToFund);
        return crystal.balanceOf(address(this));
    }

    function setPoolId(uint256 newPoolId) public onlyOwner returns (uint256) {
        require(newPoolId != pid, 'Unchanged PoolID');
        pid = newPoolId;
        getPoolInfo();
        return pid;
    }

    function setPerformanceFee(uint256 newFee) public onlyOwner returns (uint256){
        require(performanceFee != newFee, 'Unchanged Performance Fee');
        performanceFee = newFee;
        return performanceFee;
    }

    function setDepositTreasuryFee(uint256 newFee) public onlyOwner returns(uint256) {
        require(treasuryFee != newFee, 'Unchanged Treasury Fee');
        treasuryFee = newFee;
        return treasuryFee;
    }

    function setDepositVaultFee(uint256 newFee) public onlyOwner returns(uint256) {
        require(vaultFee != newFee, 'Unchanged Vault Fee');
        vaultFee = newFee;
        return vaultFee;
    }

    function setTreasuryAccount(address newAddress) public onlyOwner returns(address){
        require(newAddress != address(0) && newAddress != address(this));
        require(treasury != newAddress, 'Unchanged Treasury');
        treasury = newAddress;
        return treasury;
    }

    function setBurningVaultAccount(address newAddress) public onlyOwner returns(address){
        require(newAddress != address(0) && newAddress != address(this));
        require(burningVault != newAddress, 'Unchanged Burning Vault');
        burningVault = newAddress;
        return burningVault;
    }

    function ownerWithdrawCrystals() public onlyOwner {
        crystal.safeTransfer(msg.sender, crystal.balanceOf(address(this)));
    }

    function ownerWithdrawBUSD() public onlyOwner {
        busd.safeTransfer(msg.sender, busd.balanceOf(address(this)));
    }

    function ownerWithdrawDiamonds() public onlyOwner {
        diamond.safeTransfer(msg.sender, diamond.balanceOf(address(this)));
    }

    function ownerWithdrawLPs() public onlyOwner {
        require(pair.transfer(msg.sender, pair.balanceOf(address(this))));
    }

    function depositBUSD(uint256 amountToDeposit) noReentrant public {
        UserInfo storage user = userInfo[msg.sender];
        require(amountToDeposit > 0, 'Invalid Amount');

        require(busd.balanceOf(msg.sender) >= amountToDeposit, 'Insufficient Amount');

        require(amountToDeposit <= busd.allowance(msg.sender, address(this)), 'Allowance');

        (uint256 _feeToTake, uint256 _netAmountOfDeposit) = takeFee(
            amountToDeposit,
            depositFee
        );

        require(forwardFees(_feeToTake), 'Fee Forwarding');

        uint256 beforeBusdBalance = busd.balanceOf(address(this));

        busd.safeTransferFrom(msg.sender, address(this), _netAmountOfDeposit);

        require(busd.balanceOf(address(this)).sub(beforeBusdBalance) == _netAmountOfDeposit, 'Deposit Mismatch');

        uint256 crystalsNeeded = matchingCrystalsToBUSD(_netAmountOfDeposit);

        require(
            crystal.balanceOf(address(this)) >= crystalsNeeded,
            "Insufficient CRS"
        );

        (uint256 liquidity, bool liquidityAdded) = addLiquidity(_netAmountOfDeposit, crystalsNeeded);

        require(liquidityAdded, 'Liqudity Mismatch');

        require(makeDeposit(liquidity), 'Farming Error');

        user.lpsPlanted = user.lpsPlanted.add(calculatePlantedLPs(liquidity));
        user.busdInvested = user.busdInvested.add(_netAmountOfDeposit);
        user.crystalsAllotted = user.crystalsAllotted.add(crystalsNeeded);
        user.rewardDebt = user.lpsPlanted.mul(copiedPoolInfo.accDIAPerShare).div(1e18);

        emit MagicDeposit(msg.sender, pid, _netAmountOfDeposit, crystalsNeeded, user.lpsPlanted);
    }

    function withdrawBUSD(uint256 amountToWithdraw) noReentrant public {
        uint256 busdToSend;
        UserInfo storage user = userInfo[msg.sender];
        uint256 lpsBefore = pair.balanceOf(address(this));

        require(amountToWithdraw > 0 && amountToWithdraw <= user.lpsPlanted, "Insufficient Withdrawl");

        farms.withdraw(pid, amountToWithdraw);

        uint256 lpsAfter = pair.balanceOf(address(this));

        require((lpsAfter.sub(lpsBefore)) == amountToWithdraw, 'Withdraw Mismatch');

        uint256 rewardsToPay = pendingShare(msg.sender);
        uint256 diamondsOnHand = diamond.balanceOf(address(this));

        require(rewardsToPay <= diamondsOnHand, "Insufficient Diamonds");

        (uint256 busdReceived, bool liquidityWithdrawn) = removeLiquidity(amountToWithdraw);

        require(liquidityWithdrawn, 'Liqudity Mismatch');

        if(busdReceived > user.busdInvested && performanceFee > 0){
            uint256 busdGain = busdReceived.sub(user.busdInvested);
            uint256 fee = busdGain.mul(performanceFee).div(10000);
            busd.safeTransfer(treasury, fee);
            busdToSend = busdToSend.sub(fee);
        } else {
            busdToSend = busdReceived;
        }

        user.busdInvested = 0;
        user.crystalsAllotted = 0;
        user.lpsPlanted = 0;
        user.rewardDebt = 0;

        busd.safeTransfer(msg.sender, busdToSend);
        diamond.safeTransfer(msg.sender, rewardsToPay);

        emit MagicWithdrawl(msg.sender, pid, busdToSend, rewardsToPay);
    }

    function takeFee(uint256 amountIn, uint256 fee)
        internal
        pure
        returns (uint256, uint256)
    {
        require(amountIn >= 0, "Not enough funds sent");
        uint256 feeToTake = amountIn.mul(fee).div(10000);
        return (feeToTake, amountIn.sub(feeToTake));
    }

    function forwardFees(uint256 amountToForward) internal returns (bool) {
        uint256 toTrasury = amountToForward.mul(treasuryFee).div( depositFee);
        uint256 toVault = amountToForward.mul(vaultFee).div(depositFee);
        busd.safeTransferFrom(msg.sender, treasury, toTrasury);
        busd.safeTransferFrom(msg.sender, burningVault, toVault);
        return true;
    }

    function matchingCrystalsToBUSD(uint256 busdAmountToMatch)
        internal
        view
        returns (uint256)
    {
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = pair
            .getReserves();

        return ((reserve0 * busdAmountToMatch) / reserve1);
    }

    function addLiquidity(uint256 _netAmountOfDeposit, uint256 crystalsNeeded) internal returns (uint256, bool) {
        busd.approve(address(router), _netAmountOfDeposit);

        crystal.approve(address(router), crystalsNeeded);

        uint256 lpBefore = pair.balanceOf(address(this));

        ( , , uint256 liquidity) = IUniswapV2Router02(router).addLiquidity(
            address(busd),
            address(crystal),
            _netAmountOfDeposit,
            crystalsNeeded,
            _netAmountOfDeposit.mul(9900).div(10000),
            crystalsNeeded.mul(9900).div(10000),
            address(this),
            block.timestamp.add(600)
        );

        return (liquidity, ((pair.balanceOf(address(this)).sub(lpBefore)) == liquidity));
    }

    function removeLiquidity(uint256 amountToRemove) internal returns(uint256, bool) {
        pair.approve(address(router), amountToRemove);

        uint256 busdBefore = busd.balanceOf(address(this));

        ( uint256 busdReceived, uint256 crystalsReceived) = IUniswapV2Router02(router).removeLiquidity(
            address(busd),
            address(crystal),
            amountToRemove,
            0,
            0,
            address(this),
            block.timestamp + 600
        );

        uint256 busdAfter = busd.balanceOf(address(this));

        return ((busdAfter.sub(busdBefore)), ((busdAfter.sub(busdBefore)) == busdReceived));
    }

    function makeDeposit(uint256 amountLPsToDeposit) internal returns (bool){
        require(pair.approve(address(farms), amountLPsToDeposit), 'LPs Approval');

        farms.deposit(pid, amountLPsToDeposit);

        getPoolInfo();

        return true;
    }

    function calculatePlantedLPs(uint256 lpsDesposited) internal view returns(uint256) {
        if (copiedPoolInfo.depositFee > 0) {
            uint256 feeAmount = lpsDesposited.mul(copiedPoolInfo.depositFee).div(10000);
            return lpsDesposited.sub(feeAmount);
        } else {
            return lpsDesposited;
        }

    }

    function getPoolInfo() public returns (PoolInfo memory) {
        (
            IERC20 token,
            uint256 allocPoint,
            uint256 lastRewardTime,
            uint256 accDIAPerShare,
            bool isStarted,
            uint256 _depositFee,
            uint256 withdrawFee
        ) = farms.poolInfo(pid);

        copiedPoolInfo = PoolInfo({
            token: token,
            allocPoint: allocPoint,
            lastRewardTime: lastRewardTime,
            accDIAPerShare: accDIAPerShare,
            isStarted: isStarted,
            depositFee: _depositFee,
            withdrawFee: withdrawFee
        });

        return copiedPoolInfo;
    }

    function pendingShare(address _user) public returns (uint256) {
        PoolInfo memory pool = getPoolInfo();
        UserInfo memory user = userInfo[_user];
        uint256 accDIAPerShare = pool.accDIAPerShare;
        uint256 tokenSupply = pool.token.balanceOf(address(farms));
        if (block.timestamp > pool.lastRewardTime && tokenSupply != 0) {
            uint256 _generatedReward = farms.getGeneratedReward(
                pool.lastRewardTime,
                block.timestamp
            );
            uint256 _diamondReward = _generatedReward.mul(pool.allocPoint).div(
                farms.totalAllocPoint()
            );
            accDIAPerShare = accDIAPerShare.add(
                _diamondReward.mul(1e18).div(tokenSupply)
            );
        }

        return
            user.lpsPlanted.mul(accDIAPerShare).div(1e18).sub(user.rewardDebt);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Operator.sol";

contract DIARewardPool is Operator {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 token; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. DIAs to distribute per block.
        uint256 lastRewardTime; // Last time that DIAs distribution occurs.
        uint256 accDIAPerShare; // Accumulated DIAs per share, times 1e18. See below.
        bool isStarted; // if lastRewardTime has passed
        uint256 depositFee; // deposit fee
        uint256 withdrawFee; // withdraw fee
    }

    IERC20 public diamond;

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;

    // Fee collector address
    address public feeCollector;

    // The time when DIA mining starts.
    uint256 public poolStartTime;

    // The time when DIA mining ends.
    uint256 public poolEndTime;

    uint256 public diamondPerSecond = 0.00024511 ether; // 7730 DIA / (365 days * 24h * 60min * 60s)
    uint256 public runningTime = 365 days; // 365 days
    uint256 public constant TOTAL_REWARDS = 7730 ether;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event RewardPaid(address indexed user, uint256 amount);

    constructor(
        address _diamond,
        uint256 _poolStartTime,
        address _feeCollector
    ) {
        require(block.timestamp < _poolStartTime, "late");
        require(_diamond != address(0), "Diamond should be non-zero address");
        require(
            _feeCollector != address(0),
            "Fee Collector should be non-zero address"
        );

        diamond = IERC20(_diamond);
        feeCollector = _feeCollector;
        poolStartTime = _poolStartTime;
        poolEndTime = poolStartTime + runningTime;
    }

    function checkPoolDuplicate(IERC20 _token) internal view {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            require(poolInfo[pid].token != _token, "This pool already exist");
        }
    }

    // Add a new lp to the pool. Can only be called by the owner.
    function add(
        uint256 _allocPoint,
        IERC20 _token,
        uint256 _depositFee,
        uint256 _withdrawFee,
        bool _withUpdate,
        uint256 _lastRewardTime
    ) public onlyOperator {
        checkPoolDuplicate(_token);
        if (_withUpdate) {
            massUpdatePools();
        }
        if (block.timestamp < poolStartTime) {
            // chef is sleeping
            if (_lastRewardTime == 0) {
                _lastRewardTime = poolStartTime;
            } else {
                if (_lastRewardTime < poolStartTime) {
                    _lastRewardTime = poolStartTime;
                }
            }
        } else {
            // chef is cooking
            if (_lastRewardTime == 0 || _lastRewardTime < block.timestamp) {
                _lastRewardTime = block.timestamp;
            }
        }
        bool _isStarted = (_lastRewardTime <= poolStartTime) ||
            (_lastRewardTime <= block.timestamp);
        poolInfo.push(
            PoolInfo({
                token: _token,
                allocPoint: _allocPoint,
                lastRewardTime: _lastRewardTime,
                accDIAPerShare: 0,
                isStarted: _isStarted,
                depositFee: _depositFee,
                withdrawFee: _withdrawFee
            })
        );
        if (_isStarted) {
            totalAllocPoint = totalAllocPoint.add(_allocPoint);
        }
    }

    // Update the given pool's DIA allocation point. Can only be called by the owner.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        uint256 _depositFee,
        uint256 _withdrawFee
    ) public onlyOperator {
        require(_depositFee < 10000, "deposit fee should be less than 10000");
        require(_withdrawFee < 10000, "withdraw fee should be less than 10000");

        massUpdatePools();
        PoolInfo storage pool = poolInfo[_pid];
        if (pool.isStarted) {
            totalAllocPoint = totalAllocPoint.sub(pool.allocPoint).add(
                _allocPoint
            );
        }
        pool.allocPoint = _allocPoint;
        pool.depositFee = _depositFee;
        pool.withdrawFee = _withdrawFee;
    }

    // Set Fee Collector address
    function setFeeCollector(address _feeCollector) public onlyOperator {
        require(
            _feeCollector != address(0),
            "Fee collector should be non-zero address"
        );
        feeCollector = _feeCollector;
    }

    // Return accumulate rewards over the given _from to _to block.
    function getGeneratedReward(uint256 _fromTime, uint256 _toTime)
        public
        view
        returns (uint256)
    {
        if (_fromTime >= _toTime) return 0;
        if (_toTime >= poolEndTime) {
            if (_fromTime >= poolEndTime) return 0;
            if (_fromTime <= poolStartTime)
                return poolEndTime.sub(poolStartTime).mul(diamondPerSecond);
            return poolEndTime.sub(_fromTime).mul(diamondPerSecond);
        } else {
            if (_toTime <= poolStartTime) return 0;
            if (_fromTime <= poolStartTime)
                return _toTime.sub(poolStartTime).mul(diamondPerSecond);
            return _toTime.sub(_fromTime).mul(diamondPerSecond);
        }
    }

    // View function to see pending DIAs on frontend.
    function pendingShare(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accDIAPerShare = pool.accDIAPerShare;
        uint256 tokenSupply = pool.token.balanceOf(address(this));
        if (block.timestamp > pool.lastRewardTime && tokenSupply != 0) {
            uint256 _generatedReward = getGeneratedReward(
                pool.lastRewardTime,
                block.timestamp
            );
            uint256 _diamondReward = _generatedReward.mul(pool.allocPoint).div(
                totalAllocPoint
            );
            accDIAPerShare = accDIAPerShare.add(
                _diamondReward.mul(1e18).div(tokenSupply)
            );
        }
        return user.amount.mul(accDIAPerShare).div(1e18).sub(user.rewardDebt);
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
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }
        uint256 tokenSupply = pool.token.balanceOf(address(this));
        if (tokenSupply == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        if (!pool.isStarted) {
            pool.isStarted = true;
            totalAllocPoint = totalAllocPoint.add(pool.allocPoint);
        }
        if (totalAllocPoint > 0) {
            uint256 _generatedReward = getGeneratedReward(
                pool.lastRewardTime,
                block.timestamp
            );
            uint256 _diaReward = _generatedReward.mul(pool.allocPoint).div(
                totalAllocPoint
            );
            pool.accDIAPerShare = pool.accDIAPerShare.add(
                _diaReward.mul(1e18).div(tokenSupply)
            );
        }
        pool.lastRewardTime = block.timestamp;
    }

    // Deposit LP tokens.
    function deposit(uint256 _pid, uint256 _amount) public {
        address _sender = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 _pending = user
                .amount
                .mul(pool.accDIAPerShare)
                .div(1e18)
                .sub(user.rewardDebt);
            if (_pending > 0) {
                safeDIATransfer(_sender, _pending);
                emit RewardPaid(_sender, _pending);
            }
        }
        if (_amount > 0) {
            if (pool.depositFee > 0) {
                uint256 feeAmount = _amount.mul(pool.depositFee).div(10000);
                pool.token.safeTransferFrom(_sender, feeCollector, feeAmount);
                pool.token.safeTransferFrom(
                    _sender,
                    address(this),
                    _amount.sub(feeAmount)
                );
                user.amount = user.amount.add(_amount.sub(feeAmount));
            } else {
                pool.token.safeTransferFrom(_sender, address(this), _amount);
                user.amount = user.amount.add(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accDIAPerShare).div(1e18);
        emit Deposit(_sender, _pid, _amount);
    }

    // Withdraw LP tokens.
    function withdraw(uint256 _pid, uint256 _amount) public {
        address _sender = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 _pending = user.amount.mul(pool.accDIAPerShare).div(1e18).sub(
            user.rewardDebt
        );
        if (_pending > 0) {
            safeDIATransfer(_sender, _pending);
            emit RewardPaid(_sender, _pending);
        }
        if (_amount > 0) {
            if (pool.withdrawFee > 0) {
                uint256 feeAmount = _amount.mul(pool.withdrawFee).div(10000);
                pool.token.safeTransfer(feeCollector, feeAmount);
                pool.token.safeTransfer(_sender, _amount.sub(feeAmount));
                user.amount = user.amount.sub(_amount);
            } else {
                pool.token.safeTransfer(_sender, _amount);
                user.amount = user.amount.sub(_amount);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accDIAPerShare).div(1e18);
        emit Withdraw(_sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 _amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.token.safeTransfer(msg.sender, _amount);
        emit EmergencyWithdraw(msg.sender, _pid, _amount);
    }

    // Safe DIA transfer function, just in case if rounding error causes pool to not have enough DIAs.
    function safeDIATransfer(address _to, uint256 _amount) internal {
        uint256 _diamondBalance = diamond.balanceOf(address(this));
        if (_diamondBalance > 0) {
            if (_amount > _diamondBalance) {
                diamond.safeTransfer(_to, _diamondBalance);
            } else {
                diamond.safeTransfer(_to, _amount);
            }
        }
    }

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        if (block.timestamp < poolEndTime + 90 days) {
            // do not allow to drain core token (DIA or lps) if less than 90 days after pool ends
            require(
                _token != diamond,
                "Shouldn't drain DIA if less than 90 days after pool ends"
            );
            uint256 length = poolInfo.length;
            for (uint256 pid = 0; pid < length; ++pid) {
                PoolInfo storage pool = poolInfo[pid];
                require(
                    _token != pool.token,
                    "Shouldn't drain staking token & LPs if less than 90 days after pool ends"
                );
            }
        }
        _token.safeTransfer(_to, _amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
                /// @solidity memory-safe-assembly
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

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Operator is Context, Ownable {
    address private _operator;

    event OperatorTransferred(
        address indexed previousOperator,
        address indexed newOperator
    );

    constructor() {
        _operator = _msgSender();
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    modifier onlyOperator() {
        require(
            _operator == msg.sender,
            "operator: caller is not the operator"
        );
        _;
    }

    function isOperator() public view returns (bool) {
        return _msgSender() == _operator;
    }

    function transferOperator(address newOperator_) public onlyOwner {
        _transferOperator(newOperator_);
    }

    function _transferOperator(address newOperator_) internal {
        require(
            newOperator_ != address(0),
            "operator: zero address given for new operator"
        );
        emit OperatorTransferred(address(0), newOperator_);
        _operator = newOperator_;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}