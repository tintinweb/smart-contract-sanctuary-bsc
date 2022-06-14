// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./ReentrancyGuard.sol";
import "./IBEP20.sol";
import "./SafeBEP20.sol";
import "./IMasterChef.sol";

contract MasterChefV2 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 boostMultiplier;
    }

    struct PoolInfo {
        uint256 accKronosPerShare;
        uint256 lastRewardBlock;
        uint256 allocPoint;
        uint256 totalBoostedShare;
        uint256 depositFeeBP;
        bool isRegular;
    }

    IMasterChef public immutable MASTER_CHEF;
    IBEP20 public immutable KRONOS;

    address public burnAdmin;
    address public boostContract;
    address public feeAddress;
    address public operator;

    PoolInfo[] public poolInfo;
    IBEP20[] public lpToken;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(address => bool) public whiteList;

    uint256 public immutable MASTER_PID;

    uint256 public depositFee;
    uint256 public totalRegularAllocPoint;
    uint256 public totalSpecialAllocPoint;
    uint256 public constant MASTERCHEF_KRONOS_PER_BLOCK = 10 * 1e9;
    uint256 public constant ACC_KRONOS_PRECISION = 1e18;

    /// @notice Basic boost factor, none boosted user's boost factor
    uint256 public constant BOOST_PRECISION = 100 * 1e10;
    /// @notice Hard limit for maxmium boost factor, it must greater than BOOST_PRECISION
    uint256 public constant MAX_BOOST_PRECISION = 200 * 1e10;
    /// @notice total kronos rate = toBurn + toRegular + toSpecial
    uint256 public constant KRONOS_RATE_TOTAL_PRECISION = 1e12;
    /// @notice The last block number of KRONOS burn action being executed.
    /// @notice KRONOS distribute % for burn
    uint256 public kronosRateToBurn = 643750000000;
    /// @notice KRONOS distribute % for regular farm pool
    uint256 public kronosRateToRegularFarm = 62847222222;
    /// @notice KRONOS distribute % for special pools
    uint256 public kronosRateToSpecialFarm = 293402777778;

    uint256 public lastBurnedBlock;

    event Init();
    event AddPool(uint256 indexed pid, uint256 allocPoint, IBEP20 indexed lpToken, bool isRegular);
    event SetPool(uint256 indexed pid, uint256 allocPoint);
    event UpdatePool(uint256 indexed pid, uint256 lastRewardBlock, uint256 lpSupply, uint256 accKronosPerShare);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    event UpdateOperator(address operator);
    event UpdateKronosRate(uint256 burnRate, uint256 regularFarmRate, uint256 specialFarmRate);
    event UpdateDepositFee(uint256 depositFee);
    event UpdateBurnAdmin(address indexed oldAdmin, address indexed newAdmin);
    event UpdateFeeAddress(address feeAddress);
    event UpdateWhiteList(address indexed user, bool isValid);
    event UpdateBoostContract(address indexed boostContract);
    event UpdateBoostMultiplier(address indexed user, uint256 pid, uint256 oldMultiplier, uint256 newMultiplier);

    constructor(
        IMasterChef _MASTER_CHEF,
        IBEP20 _KRONOS,
        uint256 _MASTER_PID,
        address _burnAdmin,
        address _feeAddress
    ) public {
        MASTER_CHEF = _MASTER_CHEF;
        KRONOS = _KRONOS;
        MASTER_PID = _MASTER_PID;
        burnAdmin = _burnAdmin;
        operator = msg.sender;
        feeAddress = _feeAddress;
    }

    modifier onlyBoostContract() {
        require(boostContract == msg.sender, "Ownable: caller is not the boost contract");
        _;
    }

    modifier onlyOwnerOrOperator() {
        require(msg.sender == operator || msg.sender == owner(), "Ownable: caller is not the owner or operator");
        _;
    }

    function init(IBEP20 dummyToken) external onlyOwnerOrOperator {
        uint256 balance = dummyToken.balanceOf(msg.sender);
        require(balance != 0, "MasterChefV2: Balance must exceed 0");
        dummyToken.safeTransferFrom(msg.sender, address(this), balance);
        dummyToken.approve(address(MASTER_CHEF), balance);
        MASTER_CHEF.deposit(MASTER_PID, balance);
        lastBurnedBlock = block.number;
        emit Init();
    }

    function poolLength() public view returns (uint256 pools) {
        pools = poolInfo.length;
    }

    function add(
        uint256 _allocPoint,
        IBEP20 _lpToken,
        uint16 _depositFeeBP,
        bool _isRegular,
        bool _withUpdate
    ) external onlyOwnerOrOperator {
        require(_lpToken.balanceOf(address(this)) >= 0, "None BEP20 tokens");
        require(_lpToken != KRONOS, "KRONOS token can't be added to farm pools");

        if (_withUpdate) {
            massUpdatePools();
        }

        if (_isRegular) {
            totalRegularAllocPoint = totalRegularAllocPoint.add(_allocPoint);
        } else {
            totalSpecialAllocPoint = totalSpecialAllocPoint.add(_allocPoint);
        }
        lpToken.push(_lpToken);

        poolInfo.push(
            PoolInfo({
        allocPoint: _allocPoint,
        lastRewardBlock: block.number,
        accKronosPerShare: 0,
        depositFeeBP: _depositFeeBP,
        isRegular: _isRegular,
        totalBoostedShare: 0
        })
        );
        emit AddPool(lpToken.length.sub(1), _allocPoint, _lpToken, _isRegular);
    }

    function set(
        uint256 _pid,
        uint256 _allocPoint,
        uint16 _depositFeeBP,
        bool _withUpdate
    ) external onlyOwnerOrOperator {
        updatePool(_pid);

        if (_withUpdate) {
            massUpdatePools();
        }

        if (poolInfo[_pid].isRegular) {
            totalRegularAllocPoint = totalRegularAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        } else {
            totalSpecialAllocPoint = totalSpecialAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        }
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        emit SetPool(_pid, _allocPoint);
    }

    function pendingKRONOS(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 accKronosPerShare = pool.accKronosPerShare;
        uint256 lpSupply = pool.totalBoostedShare;

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = block.number.sub(pool.lastRewardBlock);

            uint256 kronosReward = multiplier.mul(kronosPerBlock(pool.isRegular)).mul(pool.allocPoint).div(
                (pool.isRegular ? totalRegularAllocPoint : totalSpecialAllocPoint)
            );
            accKronosPerShare = accKronosPerShare.add(kronosReward.mul(ACC_KRONOS_PRECISION).div(lpSupply));
        }

        uint256 boostedAmount = user.amount.mul(getBoostMultiplier(_user, _pid)).div(BOOST_PRECISION);
        return boostedAmount.mul(accKronosPerShare).div(ACC_KRONOS_PRECISION).sub(user.rewardDebt);
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo memory pool = poolInfo[pid];
            if (pool.allocPoint != 0) {
                updatePool(pid);
            }
        }
    }

    function kronosPerBlock(bool _isRegular) public view returns (uint256 amount) {
        if (_isRegular) {
            amount = MASTERCHEF_KRONOS_PER_BLOCK.mul(kronosRateToRegularFarm).div(KRONOS_RATE_TOTAL_PRECISION);
        } else {
            amount = MASTERCHEF_KRONOS_PER_BLOCK.mul(kronosRateToSpecialFarm).div(KRONOS_RATE_TOTAL_PRECISION);
        }
    }

    function kronosPerBlockToBurn() public view returns (uint256 amount) {
        amount = MASTERCHEF_KRONOS_PER_BLOCK.mul(kronosRateToBurn).div(KRONOS_RATE_TOTAL_PRECISION);
    }

    function updatePool(uint256 _pid) public returns (PoolInfo memory pool) {
        pool = poolInfo[_pid];
        if (block.number > pool.lastRewardBlock) {
            uint256 lpSupply = pool.totalBoostedShare;
            uint256 totalAllocPoint = (pool.isRegular ? totalRegularAllocPoint : totalSpecialAllocPoint);

            if (lpSupply > 0 && totalAllocPoint > 0) {
                uint256 multiplier = block.number.sub(pool.lastRewardBlock);
                uint256 kronosReward = multiplier.mul(kronosPerBlock(pool.isRegular)).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
                pool.accKronosPerShare = pool.accKronosPerShare.add((kronosReward.mul(ACC_KRONOS_PRECISION).div(lpSupply)));
            }
            pool.lastRewardBlock = block.number;
            poolInfo[_pid] = pool;
            emit UpdatePool(_pid, pool.lastRewardBlock, lpSupply, pool.accKronosPerShare);
        }
    }

    function deposit(uint256 _pid, uint256 _amount) external nonReentrant {
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(
            pool.isRegular || whiteList[msg.sender],
            "MasterChefV2: The address is not available to deposit in this pool"
        );

        uint256 multiplier = getBoostMultiplier(msg.sender, _pid);

        if (user.amount > 0) {
            settlePendingKronos(msg.sender, _pid, multiplier);
        }

        if (_amount > 0) {
            uint256 amount = lpToken[_pid].balanceOf(address(this));
            lpToken[_pid].safeTransferFrom(msg.sender, address(this), _amount);
            if(pool.depositFeeBP > 0){
                lpToken[_pid].safeTransfer(feeAddress, _amount.mul(pool.depositFeeBP).div(10000));
            }
            _amount = lpToken[_pid].balanceOf(address(this)).sub(amount);
            user.amount = user.amount.add(_amount);

            pool.totalBoostedShare = pool.totalBoostedShare.add(_amount.mul(multiplier).div(BOOST_PRECISION));
        }

        user.rewardDebt = user.amount.mul(multiplier).div(BOOST_PRECISION).mul(pool.accKronosPerShare).div(
            ACC_KRONOS_PRECISION
        );
        poolInfo[_pid] = pool;

        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {
        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][msg.sender];

        require(user.amount >= _amount, "withdraw: Insufficient");

        uint256 multiplier = getBoostMultiplier(msg.sender, _pid);

        settlePendingKronos(msg.sender, _pid, multiplier);

        user.amount = user.amount.sub(_amount);
        if (_amount > 0) {
            lpToken[_pid].safeTransfer(msg.sender, _amount);
        }

        user.rewardDebt = user.amount.mul(multiplier).div(BOOST_PRECISION).mul(pool.accKronosPerShare).div(
            ACC_KRONOS_PRECISION
        );
        poolInfo[_pid].totalBoostedShare = poolInfo[_pid].totalBoostedShare.sub(
            _amount.mul(multiplier).div(BOOST_PRECISION)
        );

        emit Withdraw(msg.sender, _pid, _amount);
    }

    function harvestFromMasterChef() public {
        MASTER_CHEF.deposit(MASTER_PID, 0);
    }

    function emergencyWithdraw(uint256 _pid) external nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        uint256 boostedAmount = amount.mul(getBoostMultiplier(msg.sender, _pid)).div(BOOST_PRECISION);
        pool.totalBoostedShare = pool.totalBoostedShare > boostedAmount ? pool.totalBoostedShare.sub(boostedAmount) : 0;

        lpToken[_pid].safeTransfer(msg.sender, amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function burnKronos(bool _withUpdate) public onlyOwnerOrOperator {
        if (_withUpdate) {
            massUpdatePools();
        }

        uint256 multiplier = block.number.sub(lastBurnedBlock);
        uint256 pendingKronosToBurn = multiplier.mul(kronosPerBlockToBurn());

        _safeKronosTransfer(burnAdmin, pendingKronosToBurn);
        lastBurnedBlock = block.number;
    }

    function updateKronosRate(
        uint256 _burnRate,
        uint256 _regularFarmRate,
        uint256 _specialFarmRate,
        bool _withUpdate
    ) external onlyOwnerOrOperator {
        require(
            _burnRate > 0 && _regularFarmRate > 0 && _specialFarmRate > 0,
            "MasterChefV2: Kronos rate must be greater than 0"
        );
        require(
            _burnRate.add(_regularFarmRate).add(_specialFarmRate) == KRONOS_RATE_TOTAL_PRECISION,
            "MasterChefV2: Total rate must be 1e12"
        );
        if (_withUpdate) {
            massUpdatePools();
        }
        burnKronos(false);

        kronosRateToBurn = _burnRate;
        kronosRateToRegularFarm = _regularFarmRate;
        kronosRateToSpecialFarm = _specialFarmRate;

        emit UpdateKronosRate(_burnRate, _regularFarmRate, _specialFarmRate);
    }

    function updateDepositFee(uint256 _depositFee) external onlyOwnerOrOperator {
        require(_depositFee > 0, "MasterChefV2: Deposit Fee must be greater than 0");
        depositFee = _depositFee;
        emit UpdateDepositFee(depositFee);
    }

    function updateBurnAdmin(address _newAdmin) external onlyOwnerOrOperator {
        require(_newAdmin != address(0), "MasterChefV2: Burn admin address must be valid");
        require(_newAdmin != burnAdmin, "MasterChefV2: Burn admin address is the same with current address");
        address _oldAdmin = burnAdmin;
        burnAdmin = _newAdmin;
        emit UpdateBurnAdmin(_oldAdmin, _newAdmin);
    }

    function updateFeeAddress(address _feeAddress) external onlyOwnerOrOperator {
        require(_feeAddress != address(0), "Cannot be zero address");
        feeAddress = _feeAddress;
        emit UpdateFeeAddress(feeAddress);
    }

    function updateWhiteList(address _user, bool _isValid) external onlyOwnerOrOperator {
        require(_user != address(0), "MasterChefV2: The white list address must be valid");

        whiteList[_user] = _isValid;
        emit UpdateWhiteList(_user, _isValid);
    }

    function updateBoostContract(address _newBoostContract) external onlyOwnerOrOperator {
        require(
            _newBoostContract != address(0) && _newBoostContract != boostContract,
            "MasterChefV2: New boost contract address must be valid"
        );

        boostContract = _newBoostContract;
        emit UpdateBoostContract(_newBoostContract);
    }

    function updateBoostMultiplier(
        address _user,
        uint256 _pid,
        uint256 _newMultiplier
    ) external onlyBoostContract nonReentrant {
        require(_user != address(0), "MasterChefV2: The user address must be valid");
        require(poolInfo[_pid].isRegular, "MasterChefV2: Only regular farm could be boosted");
        require(
            _newMultiplier >= BOOST_PRECISION && _newMultiplier <= MAX_BOOST_PRECISION,
            "MasterChefV2: Invalid new boost multiplier"
        );

        PoolInfo memory pool = updatePool(_pid);
        UserInfo storage user = userInfo[_pid][_user];

        uint256 prevMultiplier = getBoostMultiplier(_user, _pid);
        settlePendingKronos(_user, _pid, prevMultiplier);

        user.rewardDebt = user.amount.mul(_newMultiplier).div(BOOST_PRECISION).mul(pool.accKronosPerShare).div(
            ACC_KRONOS_PRECISION
        );
        pool.totalBoostedShare = pool.totalBoostedShare.sub(user.amount.mul(prevMultiplier).div(BOOST_PRECISION)).add(
            user.amount.mul(_newMultiplier).div(BOOST_PRECISION)
        );
        poolInfo[_pid] = pool;
        userInfo[_pid][_user].boostMultiplier = _newMultiplier;

        emit UpdateBoostMultiplier(_user, _pid, prevMultiplier, _newMultiplier);
    }

    function safeLpTokenToTreasury(uint256 _pid, uint256 _amount) external onlyOwnerOrOperator {
        if (_amount > 0) {
            uint256 balance = lpToken[_pid].balanceOf(address(this));
            if (balance < _amount) {
                _amount = balance;
            }
            lpToken[_pid].safeTransfer(feeAddress, _amount);
        }
    }

    function getBoostMultiplier(address _user, uint256 _pid) public view returns (uint256) {
        uint256 multiplier = userInfo[_pid][_user].boostMultiplier;
        return multiplier > BOOST_PRECISION ? multiplier : BOOST_PRECISION;
    }

    function settlePendingKronos(
        address _user,
        uint256 _pid,
        uint256 _boostMultiplier
    ) internal {
        UserInfo memory user = userInfo[_pid][_user];

        uint256 boostedAmount = user.amount.mul(_boostMultiplier).div(BOOST_PRECISION);
        uint256 accKronos = boostedAmount.mul(poolInfo[_pid].accKronosPerShare).div(ACC_KRONOS_PRECISION);
        uint256 pending = accKronos.sub(user.rewardDebt);
        _safeKronosTransfer(_user, pending);
    }

    function _safeKronosTransfer(address _to, uint256 _amount) internal {
        if (_amount > 0) {
            if (KRONOS.balanceOf(address(this)) < _amount) {
                harvestFromMasterChef();
            }
            uint256 balance = KRONOS.balanceOf(address(this));
            if (balance < _amount) {
                _amount = balance;
            }
            KRONOS.safeTransfer(_to, _amount);
        }
    }
}