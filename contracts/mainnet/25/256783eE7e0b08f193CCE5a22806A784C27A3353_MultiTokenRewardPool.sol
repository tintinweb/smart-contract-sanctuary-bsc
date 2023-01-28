// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "IERC20.sol";
import "SafeERC20.sol";
import "SafeMath.sol";
import "AccessControl.sol";
import "Counters.sol";
import "IEF_LiquidityContract.sol";

contract MultiTokenRewardPool is AccessControl {
    using SafeMath for uint256;
    using SafeMath for uint112;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    Counters.Counter requestedClaimIdIncrementer;
    Counters.Counter depositSeqId;
    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many  tokens the user has provided.
        // uint256 accruedCoin; // Interest accrued till date.
        uint256 claimedCoin; // Interest claimed till date
        uint256 lastAccrued; // Last date when the interest was claimed
        uint256[] depositSeqIds;
    }
    // Info for rates at different dates

    struct DepositInfo {
        address wallet;
        uint256 depositDateTime;
        uint256 stakedAmount;
        bool inactive;
        uint256 lockUpTime;
        uint256 lockUpFactor;
    }
    struct rateInfoStruct {
        uint256 timestamp;
        uint256 rate;
    }

    // Info of each pool.
    struct PoolInfo {
        address token1; // Address of investment token contract.
        address token2; // Address of investment token contract.
        bool isStarted; // if lastRewardTime has passed
        address rewardToken;
        uint256 totalStaked;
        uint256 maximumStakingAllowed;
        uint256 poolStartTime;
        uint256 poolEndTime;
        uint256 rewardsBalance;
        address lp_address;
        address treasury;
    }

    struct DepositInfoAndSeq {
        uint256 seqId;
        DepositInfo deposits;
        bool isUnlocked;
        uint256 depositInterest;
    }

    struct TotalStakeDetail {
        uint256 amount;
        uint256 interest;
        uint256 total;
        uint256 count;
    }
    //PoolId -> Start of the Day timestamp -> details
    mapping(uint256 => mapping(uint256 => TotalStakeDetail))
        public totalStakeDetails;

    // Map (date(Not a date time) => details(Amount, Interest, total, count))

    //pool-> seq -> DepositInfo
    mapping(uint256 => mapping(uint256 => DepositInfo)) public depositInfo;

    rateInfoStruct[][] public rateInfo;

    // Info of each pool.
    PoolInfo[] public poolInfo;

    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    // poolID=> time
    struct LockUpStruct {
        uint256 lockUpTime;
        uint256 lockUpFactor;
    }

    mapping(uint256 => LockUpStruct[]) public lockUpInfo; //struct withdrawalTime withdrawalfactor

    mapping(address => uint256[]) individual_user_array;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 indexed seqId,
        uint256 amount
    );
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event DepositReInvested(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event RewardPaid(address indexed user, uint256 amount);

    bytes32 public constant Operator = keccak256("OPERATOR_ROLE"); //op
    bytes32 public constant Transfer_Out_Operator = keccak256("TRANSFER_OUT_OPERATOR_ROLE"); //transferoutop
    bool public isInitialized;

    function initialize(address operator) public {
        require(!isInitialized, "Already Initialized");
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(Operator, operator);
        _setupRole(Transfer_Out_Operator, operator);
        isInitialized = true;
    }

    function checkRole(address account, bytes32 role) public view {
        require(hasRole(role, account), "Role Does Not Exist");
    } //req

    function giveRole(address wallet, uint256 _roleId) public {
        require(_roleId >= 0 && _roleId < 2, "Invalid roleId");
        checkRole(msg.sender, Operator);
        bytes32 _role;
        if (_roleId == 0) {
            _role = Operator;
        } else if (_roleId == 1) {
            _role = Transfer_Out_Operator;
        } //req
        grantRole(_role, wallet);
    }

    function revokeRole(address wallet, uint256 _roleId) public {
        require(_roleId >= 0 && _roleId < 2, "Invalid roleId");
        checkRole(msg.sender, Operator);
        bytes32 _role;
        if (_roleId == 0) {
            _role = Operator;
        } else if (_roleId == 1) {
            _role = Transfer_Out_Operator;
        }
        revokeRole(_role, wallet); //req
    }

    function renounceOwnership() public {
        checkRole(msg.sender, DEFAULT_ADMIN_ROLE);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function poolLength() public view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new farm to the pool. Can only be called by the owner.
    function add(
        address _token1,
        address _token2,
        address _rewardToken,
        uint256 _rate,
        uint256 _maximumStakingAllowed,
        uint256 _poolStartTime,
        uint256 _poolEndTime,
        address _lp_address,
        address _treasury
    ) public {
        checkRole(msg.sender, Operator);
        poolInfo.push(
            PoolInfo({
                token1: _token1,
                token2: _token2,
                rewardToken: _rewardToken,
                isStarted: false,
                totalStaked: 0,
                maximumStakingAllowed: _maximumStakingAllowed,
                poolStartTime: _poolStartTime,
                poolEndTime: _poolEndTime,
                rewardsBalance: 0,
                lp_address: _lp_address,
                treasury: _treasury
            })
        );
        rateInfo.push().push(
            rateInfoStruct({rate: _rate, timestamp: block.timestamp})
        );
    }

    // Update maxStaking. Can only be called by the owner.
    function setMaximumStakingAllowed(
        uint256 _pid,
        uint256 _maximumStakingAllowed
    ) external {
        checkRole(msg.sender, Operator);
        PoolInfo storage pool = poolInfo[_pid];
        pool.maximumStakingAllowed = _maximumStakingAllowed;
    }

    function setInterestRate(
        uint256 _pid,
        uint256 _date,
        uint256 _rate
    ) external {
        checkRole(msg.sender, Operator);
        require(
            _date >= poolInfo[_pid].poolStartTime,
            "Interest date can not be earlier than pool start date"
        );
        require(
            rateInfo[_pid][rateInfo[_pid].length - 1].timestamp < _date,
            "The date should be greater than the current last date of interest "
        );

        rateInfo[_pid].push(rateInfoStruct({rate: _rate, timestamp: _date}));
    }

    //      Ensure to set the dates in ascending order
    function setInterestRatePosition(
        uint256 _pid,
        uint256 _position,
        uint256 _date,
        uint256 _rate
    ) external {
        //        assert if date is less than pool start time.
        checkRole(msg.sender, Operator);
        require(
            _date >= poolInfo[_pid].poolStartTime,
            "Interest date can not be earlier than pool start date"
        );
        // If position is zero just update

        // first record
        if ((rateInfo[_pid].length > 1) && (_position == 0)) {
            require(
                _date <= rateInfo[_pid][_position + 1].timestamp,
                "The date should be in ascending order"
            );
        }

        // middle records
        if ((_position > 0) && (_position + 1 < rateInfo[_pid].length)) {
            require(
                _date >= rateInfo[_pid][_position - 1].timestamp,
                "The date should be in ascending order"
            );
            require(
                _date <= rateInfo[_pid][_position + 1].timestamp,
                "The date should be in ascending order"
            );
        } else if (
            (_position + 1 == rateInfo[_pid].length) && (_position > 0)
        ) {
            require(
                _date >= rateInfo[_pid][_position - 1].timestamp,
                "The date should be in ascending order"
            );
        }

        rateInfo[_pid][_position].timestamp = _date;
        rateInfo[_pid][_position].rate = _rate;
    }

    // Return accumulate rewards over the given _from to _to.
    function getGeneratedReward(
        uint256 _poolindex,
        uint256 _amount,
        uint256 _fromTime,
        uint256 _toTime,
        uint256 _lockUpFactor
    ) public view returns (uint256) {
        uint256 reward = 0;
        PoolInfo memory pool = poolInfo[_poolindex];

        // invalid cases
        if (
            (_fromTime >= _toTime) ||
            (_fromTime >= pool.poolEndTime) ||
            (_toTime <= pool.poolStartTime)
        ) {
            return 0;
        }

        // if from time < pool start then from time = pool start time
        if (_fromTime < pool.poolStartTime) {
            _fromTime = pool.poolStartTime;
        }
        //  if to time > pool end then to time = pool end time
        if (_toTime > pool.poolEndTime) {
            _toTime = pool.poolEndTime;
        }

        uint256 rateSums = 0;
        uint256 iFromTime = _fromTime;
        uint256 iToTime = _toTime;

        if (rateInfo[_poolindex].length == 1) {
            iFromTime = max(_fromTime, rateInfo[_poolindex][0].timestamp);
            // avoid any negative numbers
            iToTime = max(_toTime, iFromTime);
            rateSums = (iToTime - iFromTime) * rateInfo[_poolindex][0].rate;
        } else {
            // the loop start from 1 and not from zero; ith record and i-1 record are considered for processing.
            for (uint256 i = 1; i < rateInfo[_poolindex].length; i++) {
                if (
                    rateInfo[_poolindex][i - 1].timestamp <= _toTime &&
                    rateInfo[_poolindex][i].timestamp >= _fromTime
                ) {
                    if (rateInfo[_poolindex][i - 1].timestamp <= _fromTime) {
                        iFromTime = _fromTime;
                    } else {
                        iFromTime = rateInfo[_poolindex][i - 1].timestamp;
                    }
                    if (rateInfo[_poolindex][i].timestamp >= _toTime) {
                        iToTime = _toTime;
                    } else {
                        iToTime = rateInfo[_poolindex][i].timestamp;
                    }
                    rateSums +=
                        (iToTime - iFromTime) *
                        rateInfo[_poolindex][i - 1].rate;
                }

                // Process last block
                if (i == (rateInfo[_poolindex].length - 1)) {
                    if (rateInfo[_poolindex][i].timestamp <= _fromTime) {
                        iFromTime = _fromTime;
                    } else {
                        iFromTime = rateInfo[_poolindex][i].timestamp;
                    }
                    if (rateInfo[_poolindex][i].timestamp >= _toTime) {
                        iToTime = rateInfo[_poolindex][i].timestamp;
                    } else {
                        iToTime = _toTime;
                    }

                    rateSums +=
                        (iToTime - iFromTime) *
                        rateInfo[_poolindex][i].rate;
                }
            }
        }
        reward = reward.add(
            ((rateSums.mul(_amount)).div(10**18)).mul(_lockUpFactor)
        );
        // reward = reward.add(rateSums.mul(_amount));

        return reward.div(10**18);
    }

    function pendingShare(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {
        UserInfo memory user = userInfo[_pid][_user];
        uint256 pendings = 0;
        for (uint256 h = 0; h < user.depositSeqIds.length; h++) {
            DepositInfo memory getDeposit = depositInfo[_pid][
                user.depositSeqIds[h]
            ];
            uint256 timeStamp = 0;
            if (
                block.timestamp <=
                getDeposit.depositDateTime.add(getDeposit.lockUpTime)
            ) {
                timeStamp = block.timestamp;
            } else {
                timeStamp = getDeposit.depositDateTime.add(
                    getDeposit.lockUpTime
                );
            }
            pendings = pendings.add(
                getGeneratedReward(
                    _pid,
                    getDeposit.stakedAmount,
                    getDeposit.depositDateTime,
                    timeStamp,
                    getDeposit.lockUpFactor
                )
            );
        }

        if (pendings > 0) {
            pendings = (pendings.mul(getExchangeRate(_pid))).div(10**18);
        }

        return pendings;
    }

    // Deposit LP tokens.
    function deposit(
        uint256 _pid,
        uint256 _amount,
        uint256 _lockUpTime
    ) external {
        depositInternal(_pid, _amount, _lockUpTime, false);
    }

    function reInvest(uint256 _pid, uint256 _seqId) external {
        UserInfo storage user = userInfo[_pid][msg.sender];
        (uint256 depositIndex, bool isThere) = getRemoveIndex(
            _seqId,
            user.depositSeqIds
        );
        require(isThere, "Deposit Invalid");
        DepositInfo storage _deposit = depositInfo[_pid][_seqId];
        require(
            block.timestamp >=
                _deposit.depositDateTime.add(_deposit.lockUpTime),
            "Lockup time is not yet over!"
        );
        _deposit.inactive = true;
        user.depositSeqIds[depositIndex] = user.depositSeqIds[
            user.depositSeqIds.length - 1
        ];
        user.depositSeqIds.pop();
        uint256 _pending = getGeneratedReward(
            _pid,
            _deposit.stakedAmount,
            _deposit.depositDateTime,
            _deposit.depositDateTime.add(_deposit.lockUpTime),
            _deposit.lockUpFactor
        );

        user.lastAccrued = block.timestamp;

        if (_pending > 0) {
            _pending = (_pending.mul(getExchangeRate(_pid))).div(10**18);
            user.claimedCoin += _pending;
        }

        depositInternal(_pid, _deposit.stakedAmount, _deposit.lockUpTime, true);

        if (_pending > 0) {
            safeECoinTransfer(_pid, msg.sender, _pending);
            emit RewardPaid(msg.sender, _pending);
        }
        emit DepositReInvested(msg.sender, _pid, _deposit.stakedAmount);
    }

    function depositInternal(
        uint256 _pid,
        uint256 _amount,
        uint256 _lockUpTime,
        bool isInternal
    ) internal {
        address _sender = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_sender];
        require(
            block.timestamp >= pool.poolStartTime,
            "Pool has not started yet!"
        );
        require(
            user.amount + _amount <= pool.maximumStakingAllowed,
            "Maximum staking limit reached"
        );
        uint256 _lockUpFactor = getlockUpFactor(_pid, _lockUpTime);
        require(_lockUpFactor > 0, "Invalid LockUp Factor");
        uint256 seqId = depositSeqId.current();

        depositInfo[_pid][seqId] = DepositInfo({
            wallet: msg.sender,
            depositDateTime: block.timestamp,
            stakedAmount: _amount,
            inactive: false,
            lockUpTime: _lockUpTime,
            lockUpFactor: _lockUpFactor
        });
        if (_amount > 0) {
            user.depositSeqIds.push(seqId);
            if (!isInternal) {
                user.amount = user.amount.add(_amount);
                pool.totalStaked = pool.totalStaked.add(_amount);

                //Making one entry for the TotalStakeDetails By Day
                uint256 full_interest = getGeneratedReward(
                    _pid,
                    _amount,
                    block.timestamp,
                    block.timestamp.add(_lockUpTime),
                    _lockUpFactor
                );
                updateTotalStakeDetails(
                    _pid,
                    _amount,
                    full_interest,
                    true
                );

                IERC20(pool.token1).safeTransferFrom(
                    _sender,
                    pool.treasury,
                    _amount
                );
                IERC20(pool.token2).safeTransferFrom(
                    _sender,
                    pool.treasury,
                    _amount
                );
            }
        }
        depositSeqId.increment();
        if (!isInternal) {
            emit Deposit(_sender, _pid, _amount);
        }
    }

    function getlockUpFactor(uint256 _pid, uint256 _lockUpTime)
        internal
        view
        returns (uint256)
    {
        uint256 lockUpFactorValue;
        LockUpStruct[] memory _lockUpInfo = lockUpInfo[_pid];
        for (uint256 i; i < _lockUpInfo.length; i++) {
            if (_lockUpInfo[i].lockUpTime == _lockUpTime) {
                lockUpFactorValue = _lockUpInfo[i].lockUpFactor;
                break;
            } else {
                lockUpFactorValue = 0;
            }
        }
        return lockUpFactorValue;
    }

    function addLockUpInfo(
        uint256 _pid,
        uint256[] memory _lockUpTime,
        uint256[] memory _lockUpFactor
    ) public {
        checkRole(msg.sender, Operator);
        for (uint256 i; i < _lockUpTime.length; i++) {
            lockUpInfo[_pid].push(
                LockUpStruct({
                    lockUpTime: _lockUpTime[i],
                    lockUpFactor: _lockUpFactor[i]
                })
            );
        }
    }

    function updateLockUpInfo(
        uint256 _pid,
        uint256 _lockUpTime,
        uint256 _lockUpFactor
    ) public {
        checkRole(msg.sender, Operator);
        lockUpInfo[_pid].push(
            LockUpStruct({lockUpTime: _lockUpTime, lockUpFactor: _lockUpFactor})
        );
    }

    function updateLockUpInfoByPosition(
        uint256 _pid,
        uint256 _position,
        uint256 _lockUpTime,
        uint256 _lockUpFactor
    ) public {
        checkRole(msg.sender, Operator);
        lockUpInfo[_pid][_position] = LockUpStruct({
            lockUpTime: _lockUpTime,
            lockUpFactor: _lockUpFactor
        });
    }

    function getLockUpInfo(uint256 _pid)
        public
        view
        returns (LockUpStruct[] memory)
    {
        return lockUpInfo[_pid];
    }

    function getRemoveIndex(
        uint256 _sequenceID,
        uint256[] memory depositSequences
    ) internal pure returns (uint256, bool) {
        for (uint256 i = 0; i < depositSequences.length; i++) {
            if (_sequenceID == depositSequences[i]) {
                return (i, true);
            }
        }
        return (0, false);
    }

    function withdraw(uint256 _pid, uint256 _seqId) public {
        address _sender = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_sender];

        (uint256 depositIndex, bool isThere) = getRemoveIndex(
            _seqId,
            user.depositSeqIds
        );
        require(isThere, "Deposit Invalid");

        DepositInfo storage getDeposit = depositInfo[_pid][_seqId];
        require(user.amount >= getDeposit.stakedAmount, "Invalid withdraw");
        require(
            block.timestamp >=
                getDeposit.depositDateTime.add(getDeposit.lockUpTime),
            "Lockup time is not yet over!"
        );

        uint256 _amount = getDeposit.stakedAmount;

        uint256 _pending = getGeneratedReward(
            _pid,
            getDeposit.stakedAmount,
            getDeposit.depositDateTime,
            getDeposit.depositDateTime.add(getDeposit.lockUpTime),
            getDeposit.lockUpFactor
        );

        pool.totalStaked = pool.totalStaked.sub(_amount);

        //Making one entry for the TotalStakeDetails By Day
        uint256 full_interest = getGeneratedReward(
            _pid,
            _amount,
            getDeposit.depositDateTime,
            getDeposit.depositDateTime.add(getDeposit.lockUpTime),
            getDeposit.lockUpFactor
        );
        updateTotalStakeDetails(
            _pid,
            _amount,
            full_interest,
            false
        );

        user.lastAccrued = block.timestamp;
        user.amount = user.amount.sub(_amount);

        if (_pending > 0) {
            _pending = (_pending.mul(getExchangeRate(_pid))).div(10**18);
            user.claimedCoin += _pending;
        }

        getDeposit.inactive = true;

        user.depositSeqIds[depositIndex] = user.depositSeqIds[
            user.depositSeqIds.length - 1
        ];

        user.depositSeqIds.pop();

        if (_pending > 0) {
            safeECoinTransfer(_pid, _sender, _pending);
            emit RewardPaid(_sender, _pending);
        }
        if (_amount > 0) {
            IERC20(pool.token1).safeTransfer(_sender, _amount);
            IERC20(pool.token2).safeTransfer(_sender, _amount);
        }

        emit Withdraw(_sender, _pid, _seqId, _amount);
    }

    function updateTotalStakeDetails(
        uint256 _pid,
        uint256 _amount,
        uint256 full_interest,
        bool isAdd
    ) internal {
                uint256 today_start = getTodayStartTimeStamp();

        TotalStakeDetail memory currentStakes = totalStakeDetails[_pid][
            today_start
        ];
        if (isAdd) {
            totalStakeDetails[_pid][today_start] = TotalStakeDetail({
                amount: currentStakes.amount.add(_amount),
                interest: currentStakes.interest.add(full_interest),
                total: currentStakes.total.add(_amount.add(full_interest)),
                count: currentStakes.count + 1
            });
        } else {
            totalStakeDetails[_pid][today_start] = TotalStakeDetail({
                amount: currentStakes.amount.sub(_amount),
                interest: currentStakes.interest.sub(full_interest),
                total: currentStakes.total.sub(_amount.add(full_interest)),
                count: currentStakes.count - 1
            });
        }
    }

    // Safe SMiner transfer function, just in case if rounding error causes pool to not have enough SMiner.
    function safeECoinTransfer(
        uint256 _pid,
        address _to,
        uint256 _amount
    ) internal {
        PoolInfo storage _pool = poolInfo[_pid];
        require(
            _pool.rewardsBalance >= _amount,
            "Insufficient rewards balance, ask dev to add more miner to the gen pool"
        );

        IERC20 rewardCoin = IERC20(poolInfo[_pid].rewardToken);

        uint256 _e_CoinBal = rewardCoin.balanceOf(address(this));

        if (_e_CoinBal > 0) {
            if (_amount > _e_CoinBal) {
                _pool.rewardsBalance -= _e_CoinBal;
                rewardCoin.safeTransfer(_to, _e_CoinBal);
            } else {
                _pool.rewardsBalance -= _amount;
                rewardCoin.safeTransfer(_to, _amount);
            }
        }
    }

    // @notice Sets the pool end time to extend the gen pools if required.
    function setPoolEndTime(uint256 _pid, uint256 _pool_end_time) external {
        checkRole(msg.sender, Operator);
        poolInfo[_pid].poolEndTime = _pool_end_time;
    }

    function setPoolStartTime(uint256 _pid, uint256 _pool_start_time) external {
        checkRole(msg.sender, Operator);
        poolInfo[_pid].poolStartTime = _pool_start_time;
    }

    // @notice imp. only use this function to replenish rewards
    function replenishReward(uint256 _pid, uint256 _value) external {
        checkRole(msg.sender, Operator);
        require(_value > 0, "replenish value must be greater than 0");
        IERC20(poolInfo[_pid].rewardToken).safeTransferFrom(
            msg.sender,
            address(this),
            _value
        );
        poolInfo[_pid].rewardsBalance += _value;
    }

    // @notice imp. only use this function to replenish rewards
    function replenishDepositTokens(uint256 _pid, uint256 _value) external {
        checkRole(msg.sender, Operator);
        require(_value > 0, "replenish value must be greater than 0");
        address _sender = msg.sender;
        PoolInfo storage pool = poolInfo[_pid];
        IERC20(pool.token1).safeTransferFrom(_sender, address(this), _value);
        IERC20(pool.token2).safeTransferFrom(_sender, address(this), _value);
    }


    function transferOutECoin(
        uint256 _pid,
        address _to,
        uint256 _value
    ) external {
        checkRole(msg.sender, Transfer_Out_Operator);
        PoolInfo storage pool = poolInfo[_pid];
        require(
            _value <= pool.rewardsBalance,
            "Trying to transfer out more miner than available"
        );
        pool.rewardsBalance -= _value;
        IERC20(pool.rewardToken).safeTransfer(_to, _value);
    }

    function transferOutStakes(
        address _token,
        address _to,
        uint256 _value
    ) external {
        checkRole(msg.sender, Transfer_Out_Operator);
        require(
            _value <= IERC20(_token).balanceOf(address(this)),
            "Trying to transfer out more stakes than available"
        );

        IERC20(_token).safeTransfer(_to, _value);
    }

    // @notice sets a pool's isStarted to true and increments total allocated points
    //function startPool(uint256 _pid) external onlyOperator { [RP] compilation error
    function startPool(uint256 _pid) public {
        checkRole(msg.sender, Operator);
        PoolInfo storage pool = poolInfo[_pid];
        if (!pool.isStarted) {
            pool.isStarted = true;
        }
    }

    // @notice calls startPool for all pools
    function startAllPools() external {
        checkRole(msg.sender, Operator);
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            startPool(pid);
        }
    }

    // View function to see rewards balance.
    function getRewardsBalance(uint256 _pid) external view returns (uint256) {
        return poolInfo[_pid].rewardsBalance;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function getLatestRate(uint256 _pid) external view returns (uint256) {
        return rateInfo[_pid][rateInfo[_pid].length - 1].rate;
    }

    function fetchDepositSeqList(uint256 _poolID, address _sender)
        external
        view
        returns (uint256[] memory)
    {
        return userInfo[_poolID][_sender].depositSeqIds;
    }

    function fetchDepositsInfo(uint256 _poolID, address _sender)
        external
        view
        returns (DepositInfoAndSeq[] memory)
    {
        uint256[] memory depSeqIds = userInfo[_poolID][_sender].depositSeqIds;
        DepositInfoAndSeq[] memory user_deposits = new DepositInfoAndSeq[](
            depSeqIds.length
        );
        for (uint256 i = 0; i < depSeqIds.length; i++) {
            DepositInfo memory getDeposit = depositInfo[_poolID][depSeqIds[i]];

            if (
                block.timestamp <=
                getDeposit.depositDateTime.add(getDeposit.lockUpTime)
            ) {
                uint256 pendings = getGeneratedReward(
                    _poolID,
                    getDeposit.stakedAmount,
                    getDeposit.depositDateTime,
                    block.timestamp,
                    getDeposit.lockUpFactor
                );
                if (pendings > 0) {
                    pendings = (pendings.mul(getExchangeRate(_poolID))).div(
                        10**18
                    );
                }
                user_deposits[i] = DepositInfoAndSeq({
                    seqId: depSeqIds[i],
                    deposits: getDeposit,
                    isUnlocked: false,
                    depositInterest: pendings
                });
            } else {
                uint256 pendings = getGeneratedReward(
                    _poolID,
                    getDeposit.stakedAmount,
                    getDeposit.depositDateTime,
                    getDeposit.depositDateTime.add(getDeposit.lockUpTime),
                    getDeposit.lockUpFactor
                );
                if (pendings > 0) {
                    pendings = (pendings.mul(getExchangeRate(_poolID))).div(
                        10**18
                    );
                }
                user_deposits[i] = DepositInfoAndSeq({
                    seqId: depSeqIds[i],
                    deposits: getDeposit,
                    isUnlocked: true,
                    depositInterest: pendings
                });
            }
        }
        return (user_deposits);
    }

    function getExchangeRate(uint256 _pid) public view returns (uint256) {
        PoolInfo memory _pool = poolInfo[_pid];
        IEF_LiquidityContract _iLiquidity = IEF_LiquidityContract(_pool.lp_address);
        
        (
            uint256 reserve0,
            uint256 reserve1,
            uint256 blockTimestampLast
        ) = _iLiquidity.getReserves();
        uint256 diff = reserve0.mul(10**18).div(reserve1);
        return diff;
    }

    function setTreasury(uint256 _pid, address _treasury) external {
        checkRole(msg.sender, Operator);
        poolInfo[_pid].treasury = _treasury;
    }
    
    function setLPaddress(uint256 _pid, address _lpaddress) external {
        checkRole(msg.sender, Operator);
        poolInfo[_pid].lp_address = _lpaddress;
    }

    function getTodayStartTimeStamp() public view returns (uint256) {
        return (block.timestamp - (block.timestamp % 86400));
    }

}

// SPDX-License-Identifier: MIT

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity ^0.8.0;

import "IERC20.sol";
import "Address.sol";

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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "Context.sol";
import "ERC165.sol";

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEF_LiquidityContract {

    function giveRole(address wallet, uint256 _roleId) external;

    function revokeRole(address wallet, uint256 _roleId) external ;

    function renounceOwnership() external ;

    function transferOut(
        address _token,
        address _to,
        uint256 _value
    ) external ;
    function exchangeCoin(
        address token_0,
        address token_1,
        uint256 _amount
    ) external ;

    function setReserverConstant(uint256 _reserver_constant) external ;

    function setTaxId(uint256 _tax_Id) external;
    function getReserves()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    ;
     function getExchangeDetails()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    ;
}