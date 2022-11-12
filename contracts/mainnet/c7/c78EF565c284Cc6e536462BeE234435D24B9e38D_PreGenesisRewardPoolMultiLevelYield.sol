// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "IERC20.sol";
import "SafeERC20.sol";
import "SafeMath.sol";
import "Counters.sol";

library CustomMath {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
}

contract PreGenesisRewardPoolMultiLevelYield {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    address public operator;
    address public transferOutOperator;

    struct Level {
        uint256 amount;
        uint256 level; // 0 is the highest level; n is the lowest level
    }
    //    struct LevelInfoForEachUser {
    struct DepositInfo {
        address wallet;
        uint256 depositDateTime; // UTC
        uint256 initialStakedAmount;
        uint256 iCoinValue;
        uint256 stakedAmount;
        uint256 accuredCoin;
        uint256 claimedCoin;
        uint256 lastUpdated;
        uint256 nextSequenceID;
        uint256 previousSequenceID;
        uint256 inactive;
    }
    //poolID => seqID => list of levels
    mapping(uint256 => mapping(uint256 => mapping(uint8 => uint256)))
        public lastUpdatedLevelForDeposits;
    //    Levels[][][] public lastUpdatedLevelForDeposits;
    //pool-> seq -> DepositInfo
    mapping(uint256 => mapping(uint256 => DepositInfo)) public depositInfo;
    // Info of each user.
    struct UserInfo {
        uint256 initialStakedAmount;
        uint256 totalAmount; // How many  tokens the user has provided.
        uint256 totalAccrued; // Interest accrued till date.
        uint256 totalClaimedCoin; // Interest claimed till date
        uint256 lastAccrued; // Last date when the interest was claimed
        uint256[] depositSequences;
    }
    // Info of each user that stakes LP tokens.
    // wallet -> poolId
    mapping(address => mapping(uint256 => UserInfo)) public userInfo;
    // poolId => wallet => levelID
    // Info for rates at different dates
    struct rateInfoStruct {
        uint256 timestamp;
        uint256 rate;
    }
    //    poolID -> LevelID-> Rate
    rateInfoStruct[][][] public rateInfo;
    //Level Structure
    struct LevelInfo {
        uint256 levelStakingLimit;
        uint256 levelStaked;
    }
    //Pool -> levels
    //    levelInfo[][] public levelsInfo;
    mapping(uint256 => mapping(uint256 => LevelInfo)) public levelsInfo;
    // Info of each pool.
    struct PoolInfo {
        string name; //Pool name
        uint256 totalStaked; //
        uint256 eInvestCoinValue;
        IERC20 depositToken; // Address of investment token contract.
        IERC20 rewardToken; // Address of reward token contract.
        bool isStarted;
        uint256 maximumStakingAllowed;
        uint256 currentSequence;
        // The time when miner mining starts.
        uint256 poolStartTime;
        // The time when miner mining ends.
        uint256 poolEndTime;
        uint256 rewardsBalance; // = 0;
        uint256 levels;
        uint256 lastActiveSequence;
        uint256[] taxRates; // [deposit dev, deposit Protocol, withdraw dev, withdraw Protocol]
    }
    // Info of each pool.
    PoolInfo[] public poolInfo;

    mapping(uint256 => bool) poolIsPrivate;

    mapping(address => bool) preApprovedUsers;

    mapping(uint256 => Counters.Counter) currentSequenceIncrement;

    // Info of each pool.
    mapping(uint256 => address) public treasury;

    struct Threshold {
        uint256 sequence;
        uint256 amount;
    }
    //    pool ->levels -> Threshold
    //    Threshold[][] public currentThresholds; // have information about threshold levels for a given pool
    mapping(uint256 => mapping(uint256 => Threshold)) public currentThresholds;
    uint256 public withdrawTime = 86400; // 24 hours

    struct RequestedClaimInfo {
        uint256 claimId;
        uint256 claimTime;
        uint256 claimAmount;
        uint256 depositAmount;
        uint256 claimInterest;
    }

    mapping(address => mapping(uint256 => RequestedClaimInfo[]))
        public requestedClaimInfo;

    Counters.Counter requestedClaimIdIncrementer;
    //Treasury address
//    address e_Treasury;
    address[] taxAddress;

    // mapping(address => uint256) public sequenceByAddress;
    event Log(uint256 var1, uint256 var2, uint256 var3);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event RewardPaid(address indexed user, uint256 amount);

    constructor(address _devTaxAddress, address _protocalTaxAddress) public {
        operator = msg.sender;
        transferOutOperator = msg.sender;
        address[] memory _taxAddress = new address[](2);
        _taxAddress[0] = _devTaxAddress;
        _taxAddress[1] = _protocalTaxAddress;
        taxAddress = _taxAddress;
    }

    modifier onlyOperator() {
        require(operator == msg.sender, "Not operator");
        _;
    }

    modifier onlyTransferOutOperator() {
        require(
            transferOutOperator == msg.sender,
            "Invalid operator"
        );
        _;
    }

    function setCurrentThresholds(uint256 _pid,uint256 _level,uint256 _sequence, uint256 _amount)  public onlyOperator
    {
        currentThresholds[_pid][_level].sequence = _sequence;
        currentThresholds[_pid][_level].amount = _amount;
    }

    function returnDepositSeqList(uint256 _poodID, address _sender)
        external
        view
        returns (uint256[] memory)
    {
        return userInfo[_sender][_poodID].depositSequences;
    }
    // Add a new farm to the pool. Can only be called by the owner.
    function add(
        string memory _name,
        address _depositToken,
        address _rewardToken,
        uint256 _maximumStakingAllowed,
        uint256 _poolStartTime,
        uint256 _poolEndTime,
        uint256 _levelStakingLimit,
        uint256 _rate,
        address _treasury,
        uint256 _pid,
        bool _isPrivate
    ) public onlyOperator {
        require(poolInfo.length == _pid, "PID wrong");

        //Defaulting tax rates
        // [deposit dev, deposit Protocol, withdraw dev, withdraw Protocol]
        uint256[] memory _taxRates = new uint256[](4);

        // _taxRates[0] = 0.25 * 1000000000000000000;
        // _taxRates[1] = 0.75 * 1000000000000000000;
        // _taxRates[2] = 1 * 1000000000000000000;
        // _taxRates[3] = 3 * 1000000000000000000;

        poolInfo.push(
            PoolInfo({
                name: _name,
                totalStaked: 0,
                eInvestCoinValue: 1000000000000000000,
                depositToken: IERC20(_depositToken),
                rewardToken: IERC20(_rewardToken),
                isStarted: false,
                maximumStakingAllowed: _maximumStakingAllowed,
                currentSequence: 0,
                poolStartTime: _poolStartTime,
                poolEndTime: _poolEndTime,
                rewardsBalance: 0,
                levels: 1,
                lastActiveSequence: 0,
                taxRates: _taxRates // [deposit dev, deposit Protocol, withdraw dev, withdraw Protocol]
            })
        );

        poolIsPrivate[_pid] = _isPrivate;

        treasury[_pid] = _treasury;
        levelsInfo[_pid][0] = LevelInfo({
            levelStaked: 0,
            levelStakingLimit: _levelStakingLimit
        });
        //pool -> level -> rate
        rateInfo.push().push().push(
            rateInfoStruct({rate: _rate, timestamp: block.timestamp})
        );
        // add a deposit block with zero as sequence. This is a genesis deposit block

        depositInfo[_pid][0] = DepositInfo({
            wallet: address(0),
            depositDateTime: block.timestamp, // UTC
            initialStakedAmount: 0,
            iCoinValue: (1 * 10) ^ 18,
            stakedAmount: 0,
            accuredCoin: 0,
            claimedCoin: 0,
            lastUpdated: block.timestamp,
            nextSequenceID: 0,
            previousSequenceID: 0,
            inactive: 0
        });
        lastUpdatedLevelForDeposits[_pid][0][0] = 0;
        currentThresholds[_pid][0] = Threshold({sequence: 0, amount: 0});
    }

    function addLevelsInfo(
        uint256 _poolID,
        uint256 _rate,
        uint256 _levelStakingLimit,
        uint256 _level
    ) public onlyOperator {
        require(_level == poolInfo[_poolID].levels, "Level mismatch");
        levelsInfo[_poolID][_level] = LevelInfo({
            levelStaked: 0,
            levelStakingLimit: _levelStakingLimit
        });
        rateInfo[_poolID].push().push(
            rateInfoStruct({rate: _rate, timestamp: block.timestamp})
        );

        currentThresholds[_poolID][_level] = Threshold({
            sequence: 0,
            amount: 0
        });

        poolInfo[_poolID].levels++;
    }

    function updateLevelInfoGlobal(
        uint256 _poolID,
        uint256 _levelID,
        // uint256 _levelStaked,
        uint256 _levelStakingLimit
    ) public onlyOperator {
        bool isIncrease = false;
        uint256 gap = 0;

        if (
            levelsInfo[_poolID][_levelID].levelStakingLimit < _levelStakingLimit
        ) {
            isIncrease = true;
            gap = _levelStakingLimit.sub(
                levelsInfo[_poolID][_levelID].levelStakingLimit
            );
        } else {
            gap = levelsInfo[_poolID][_levelID].levelStakingLimit.sub(
                _levelStakingLimit
            );
        }

        levelsInfo[_poolID][_levelID].levelStakingLimit = _levelStakingLimit;
        // create gap and progress.

        uint256[] memory levelUpdateAmounts = new uint256[](
            poolInfo[_poolID].levels
        );
        levelUpdateAmounts[_levelID] = gap;
        updateLevelForBlockRemoval(_poolID, levelUpdateAmounts, true);
        //set 1 for global limit increase

        for (uint256 i = _levelID; i < poolInfo[_poolID].levels; i++) {
            //No blocks available for moving

            if (levelsInfo[_poolID][i].levelStaked == 0) {
                currentThresholds[_poolID][i].amount = 0;
                currentThresholds[_poolID][i].sequence = 0;
                break;
            }
            adjustThresholdForLevelUpdate(_poolID, i, gap, isIncrease);
        }
    }

    //Updated
    function setInterestRate(
        uint256 _pid,
        uint256 _levelID,
        uint256 _date,
        uint256 _rate
    ) external onlyOperator {
        require(
            _date >= poolInfo[_pid].poolStartTime,
            "Interest date is earlier"
        );
        require(
            rateInfo[_pid][_levelID][rateInfo[_pid][_levelID].length - 1]
                .timestamp < _date,
            "Date should be greater than last "
        );

        rateInfo[_pid][_levelID].push(
            rateInfoStruct({rate: _rate, timestamp: _date})
        );
    }

    // Update maxStaking. Can only be called by the owner.
    function setMaximumStakingAllowed(
        uint256 _pid,
        uint256 _maximumStakingAllowed
    ) external onlyOperator {
        poolInfo[_pid].maximumStakingAllowed = _maximumStakingAllowed;
    }

    //      Ensure to set the dates in ascending order
    function setInterestRatePosition(
        uint256 _pid,
        uint256 _levelID,
        uint256 _position,
        uint256 _date,
        uint256 _rate
    ) external onlyOperator {
        //        assert if date is less than pool start time.
        require(
            _date >= poolInfo[_pid].poolStartTime,
            "Interest date is early"
        );
        // If position is zero just update

        // first record
        if ((rateInfo[_pid][_levelID].length > 1) && (_position == 0)) {
            require(
                _date <= rateInfo[_pid][_levelID][_position + 1].timestamp,
                "The date not in asc order"
            );
        }

        // middle records
        if (
            (_position > 0) && (_position + 1 < rateInfo[_pid][_levelID].length)
        ) {
            require(
                (_date >= rateInfo[_pid][_levelID][_position - 1].timestamp &&
                    _date <= rateInfo[_pid][_levelID][_position + 1].timestamp),
                "The date not in asc"
            );
        } else if (
            (_position + 1 == rateInfo[_pid][_levelID].length) &&
            (_position > 0)
        ) {
            require(
                _date >= rateInfo[_pid][_levelID][_position - 1].timestamp,
                "The date should be in asc order"
            );
        }

        rateInfo[_pid][_levelID][_position].timestamp = _date;
        rateInfo[_pid][_levelID][_position].rate = _rate;
    }

    // Return accumulate rewards over the given _from to _to block.
    function getGeneratedRewardForSequence(
        uint256 _poolindex,
        uint256 _sequence,
        uint256 _amount,
        uint256 _fromTime,
        uint256 _toTime
    ) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_poolindex];

        uint256 reward = 0;
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
        uint256 iFromTime;
        uint256 iToTime;
        uint256 iAmount = 0;
        // for each levels in levelForDeposit
        for (uint8 iLevel = 0; iLevel < pool.levels - 1; iLevel++) {
            iAmount = lastUpdatedLevelForDeposits[_poolindex][_sequence][
                iLevel
            ];
            if (iAmount <= 0) continue;

            rateSums = 0;
            iFromTime = _fromTime;
            iToTime = _toTime;

            if (rateInfo[_poolindex][iLevel].length == 1) {
                iFromTime = CustomMath.max(
                    _fromTime,
                    rateInfo[_poolindex][iLevel][0].timestamp
                );
                // avoid any negative numbers
                iToTime = CustomMath.max(_toTime, iFromTime);
                rateSums =
                    (iToTime - iFromTime) *
                    rateInfo[_poolindex][iLevel][0].rate;
            } else {
                // the loop start from 1 and not from zero; ith record and i-1 record are considered for processing.
                for (
                    uint256 i = 1;
                    i < rateInfo[_poolindex][iLevel].length;
                    i++
                ) {
                    if (
                        rateInfo[_poolindex][iLevel][i - 1].timestamp <=
                        _toTime &&
                        rateInfo[_poolindex][iLevel][i].timestamp >= _fromTime
                    ) {
                        if (
                            rateInfo[_poolindex][iLevel][i - 1].timestamp <=
                            _fromTime
                        ) {
                            iFromTime = _fromTime;
                        } else {
                            iFromTime = rateInfo[_poolindex][iLevel][i - 1]
                                .timestamp;
                        }
                        if (
                            rateInfo[_poolindex][iLevel][i].timestamp >= _toTime
                        ) {
                            iToTime = _toTime;
                        } else {
                            iToTime = rateInfo[_poolindex][iLevel][i].timestamp;
                        }
                        rateSums +=
                            (iToTime - iFromTime) *
                            rateInfo[_poolindex][iLevel][i - 1].rate;
                    }

                    // Process last block
                    if (i == (rateInfo[_poolindex][iLevel].length - 1)) {
                        if (
                            rateInfo[_poolindex][iLevel][i].timestamp <=
                            _fromTime
                        ) {
                            iFromTime = _fromTime;
                        } else {
                            iFromTime = rateInfo[_poolindex][iLevel][i]
                                .timestamp;
                        }
                        if (
                            rateInfo[_poolindex][iLevel][i].timestamp >= _toTime
                        ) {
                            iToTime = rateInfo[_poolindex][iLevel][i].timestamp;
                        } else {
                            iToTime = _toTime;
                        }

                        rateSums +=
                            (iToTime - iFromTime) *
                            rateInfo[_poolindex][iLevel][i].rate;
                    }
                }
            }
            reward = reward + ((rateSums * _amount) / (1000000000000000000));
        }
        return reward;
    }

    function addDepositInfoAndUpdateChain(
        uint256 _pid,
        address _sender,
        uint256 _amount
    ) internal returns (uint256) {
        // new entry for current deposit
        PoolInfo storage pool = poolInfo[_pid];
        currentSequenceIncrement[_pid].increment();
        pool.currentSequence = currentSequenceIncrement[_pid].current();
        depositInfo[_pid][pool.currentSequence] = DepositInfo({
            wallet: _sender,
            depositDateTime: block.timestamp, // UTC
            initialStakedAmount: _amount,
            iCoinValue: pool.eInvestCoinValue,
            stakedAmount: _amount,
            lastUpdated: block.timestamp,
            nextSequenceID: 0,
            previousSequenceID: poolInfo[_pid].lastActiveSequence,
            accuredCoin: 0,
            claimedCoin: 0,
            inactive: 0
        });

        // update the linkedList to include the current chain
        depositInfo[_pid][pool.lastActiveSequence].nextSequenceID = pool
            .currentSequence;

        // update the lastActiveSequence
        pool.lastActiveSequence = pool.currentSequence;

        return pool.currentSequence;
    }

    function calculateAmountSplitAcrossLevels(uint256 _pid, uint256 _amount)
        internal
        view
        returns (uint256[] memory)
    {
        uint256[] memory _levels = new uint256[](poolInfo[_pid].levels);
        uint256 next_level_transaction_amount = _amount;
        uint256 current_level_availability;

        for (uint256 i = 0; i < poolInfo[_pid].levels; i++) {
            current_level_availability = SafeMath.sub(
                levelsInfo[_pid][i].levelStakingLimit,
                levelsInfo[_pid][i].levelStaked
            );
            if (next_level_transaction_amount <= current_level_availability) {
                // push only if greater than zero
                if (next_level_transaction_amount > 0) {
                    _levels[i] = next_level_transaction_amount;
                }
                break;
            }
            if (i == poolInfo[_pid].levels - 1) {
                require(
                    next_level_transaction_amount <= current_level_availability,
                    "Could not deposit complete amount"
                );
            }
            // push only if greater than zero
            if (current_level_availability > 0) {
                _levels[i] = current_level_availability;
            }
            next_level_transaction_amount = SafeMath.sub(
                next_level_transaction_amount,
                current_level_availability
            );
        }

        return _levels;
    }

    //This function maintain the user initiated last level for each deposit.
    function updateLevelsForDeposit(
        uint256 _pid,
        uint256 _sequence,
        uint256[] memory _depositSplit
    ) internal {
        //todo : check if zero amount can be skipped
        for (uint8 i = 0; i < _depositSplit.length; i++) {
            lastUpdatedLevelForDeposits[_pid][_sequence][i] = _depositSplit[i];
        }
    }

    function updateLevelInfo(uint256 _pid, uint256[] memory depositSplit)
        internal
    {
        for (uint256 i = 0; i < depositSplit.length; i++) {
            levelsInfo[_pid][i].levelStaked = levelsInfo[_pid][i]
                .levelStaked
                .add(depositSplit[i]);
        }
    }

    function updateUserInfo(
        uint256 _pid,
        uint256 _sequenceID,
        uint256 _amount
    ) internal {
        userInfo[msg.sender][_pid].lastAccrued = block.timestamp;
        userInfo[msg.sender][_pid].depositSequences.push(_sequenceID);
        userInfo[msg.sender][_pid].initialStakedAmount = userInfo[msg.sender][
            _pid
        ].initialStakedAmount.add(_amount);
        userInfo[msg.sender][_pid].totalAmount = userInfo[msg.sender][_pid]
            .totalAmount
            .add(_amount);
    }

    function updatePoolInfo(
        uint256 _pid,
        uint256 _amount,
        uint256 _sequenceID
    ) internal {
        poolInfo[_pid].totalStaked = poolInfo[_pid].totalStaked.add(_amount);
        poolInfo[_pid].lastActiveSequence = _sequenceID;
    }

    function updateThresholdsForDeposit(
        uint256 _pid,
        uint256[] memory depositSplit,
        uint256 _sequence
    ) internal {
        //     There will be n-1 currentThresholds
        //     elements are added already; n - no of levels
        //     process seperately for n = 1; 0 -> poolInfo.lastActiveSequence with 100% amount
        if (poolInfo[_pid].levels == 1) {
            currentThresholds[_pid][0] = Threshold({
                sequence: poolInfo[_pid].lastActiveSequence,
                amount: depositSplit[0]
            });
        }

        //        in a loop i from 0 to n-2
        for (uint256 i = 0; i <= depositSplit.length - 1; i++) {
            //        Case 1: 100% amount is in ith level  => move threshold to current block
            if (depositSplit[i] != 0) {
                currentThresholds[_pid][i] = Threshold({
                    sequence: _sequence,
                    amount: depositSplit[i]
                });
            }
        }
    }

    function deposit(uint256 _pid, uint256 _amount) external {
        if (poolIsPrivate[_pid]) {
            require(
                preApprovedUsers[msg.sender],
                "User does not have pre-approval"
            );
            depositInternal(_pid, _amount, false);
        } else {
            depositInternal(_pid, _amount, false);
        }
    }

    function depositInternal(
        uint256 _pid,
        uint256 _amount,
        bool isInternal
    ) internal {
        //Verifications
        //        1. Blocktime greater than or equal to poolstart time
        require(
            block.timestamp >= poolInfo[_pid].poolStartTime,
            "Pool has not started yet!"
        );

        //        2. Blocktime less than poolstart time
        require(
            block.timestamp < poolInfo[_pid].poolEndTime,
            "Pool has ended already!"
        );

        //        3. [existing amount + current investment] <= maximum amount
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[msg.sender][_pid];
        require(
            user.totalAmount + _amount <= pool.maximumStakingAllowed,
            "Maximum staking limit reached"
        );

        // Financial transaction
        // 1. Transfer Deposit token to treasury from the user
        if (!isInternal) {
            _amount = getTaxedAmount(true, _pid, _amount);
            IERC20(poolInfo[_pid].depositToken).safeTransferFrom(
                msg.sender,
                treasury[_pid],
                _amount
            );
        }
        //        // 3. Stake the eInvest into pool
        //        stakeEInvestToken(_pid, minterEInvestToken);

        //Data storage
        //1. Blindly add to depositInfo after creating sequence
        uint256 sequenceID = addDepositInfoAndUpdateChain(
            _pid,
            msg.sender,
            _amount
        );
        //2. Calculate amountsplit
        uint256[] memory depositSplit = calculateAmountSplitAcrossLevels(
            _pid,
            _amount
        );
        //3. Update lastUpdatedLevelForDeposits
        updateLevelsForDeposit(_pid, sequenceID, depositSplit);
        //4. UpdateUserinfo - incase of no entry add entry also
        updateUserInfo(_pid, sequenceID, _amount);

        //5.Update Level info
        updateLevelInfo(_pid, depositSplit);

        //6. Update poolinfo
        // Store current Sequence ID in the pool. When doing new deposit always increase it.
        updatePoolInfo(_pid, _amount, sequenceID);
        //7.Update Thresholds
        updateThresholdsForDeposit(_pid, depositSplit, sequenceID);
    }

    function removeDepositBlockAndUpdatePool(
        uint256 _pid,
        uint256 _sequenceID,
        uint256 _interest
    ) internal {
        DepositInfo storage _depositPrevious = depositInfo[_pid][
            depositInfo[_pid][_sequenceID].previousSequenceID
        ];
        DepositInfo storage _depositNext = depositInfo[_pid][
            depositInfo[_pid][_sequenceID].nextSequenceID
        ];
        DepositInfo storage _deposit = depositInfo[_pid][_sequenceID];
        //Previous
        _depositPrevious.nextSequenceID = _deposit.nextSequenceID;
        //Next
        if (_deposit.nextSequenceID > _sequenceID) {
            _depositNext.previousSequenceID = _deposit.previousSequenceID;
        }

        //current
        _deposit.accuredCoin += _interest;
        _deposit.claimedCoin = _deposit.accuredCoin;
        _deposit.lastUpdated = block.timestamp;

        poolInfo[_pid].totalStaked -= _deposit.stakedAmount;
        if (_sequenceID == poolInfo[_pid].lastActiveSequence) {
            poolInfo[_pid].lastActiveSequence = _deposit.previousSequenceID;
        }

        for (uint256 i = 0; i <= poolInfo[_pid].levels - 1; i++) {
            if (currentThresholds[_pid][i].sequence == _sequenceID) {
                if (_deposit.previousSequenceID != 0) {
                    currentThresholds[_pid][i].amount = getThresholdInfo(
                        _pid,
                        _deposit.previousSequenceID
                    )[i];
                    currentThresholds[_pid][i].sequence = _deposit
                        .previousSequenceID;
                } else if (_deposit.previousSequenceID == 0) {
                    currentThresholds[_pid][i].amount = 0;
                    currentThresholds[_pid][i].sequence = _deposit
                        .previousSequenceID;
                }
            }
        }
        _deposit.nextSequenceID = 0;
        _deposit.previousSequenceID = 0;
        _deposit.inactive = 1;
    }

    // returns split of the deposit of the sequence across different levels.
    function getThresholdInfo(uint256 _pid, uint256 _sequenceID)
        public
        view
        returns (uint256[] memory)
    {
        uint256 iStakedAmount = depositInfo[_pid][_sequenceID]
            .initialStakedAmount;
        uint256[] memory ths = new uint256[](poolInfo[_pid].levels);
        Threshold storage th;
        uint256 pos = 0;

        for (uint256 i = 0; i < poolInfo[_pid].levels; i++) {
            if (iStakedAmount <= 0) break;

            th = currentThresholds[_pid][i];
            if (th.sequence < _sequenceID) {
                //                ths.push(0);
                ths[i] = 0;
                continue;
            } else if (th.sequence > _sequenceID) {
                ths[i] = iStakedAmount;
                pos++;
                break;
            } else if (th.sequence == _sequenceID) {
                ths[i] = th.amount;
                pos++;
                if (iStakedAmount >= th.amount) {
                    iStakedAmount = iStakedAmount.sub(th.amount);
                } else {
                    iStakedAmount = 0;
                }
                continue;
            }
        }
        return ths;
    }

    // set addFlag = 1 when adding more slab limit
    function updateLevelForBlockRemoval(
        uint256 _pid,
        uint256[] memory _ths,
        bool addFlag
    ) internal {
        // uint256 amountToMove;
        bool iStarted = false;
        uint256 iStart = 0;
        uint256 iSum = 0;

        for (uint256 i = 0; i < _ths.length; i++) {
            // exclude this condition if addFlag is 1
            if (
                _ths[i] > 0 &&
                iStarted == false &&
                ((levelsInfo[_pid][i].levelStaked >= _ths[i]) || addFlag)
            ) {
                iStarted = true;
                iStart = i;
                iSum = levelsInfo[_pid][i].levelStaked;
                if (!addFlag) {
                    iSum = iSum.sub(_ths[i]);
                }
            } else if (levelsInfo[_pid][i].levelStaked >= _ths[i]) {
                iSum += levelsInfo[_pid][i].levelStaked;
                if (!addFlag) {
                    iSum = iSum.sub(_ths[i]);
                }
            }
        }
        for (
            uint256 i = iStart;
            i < poolInfo[_pid].levels;
            i++ // iEnd  upto all levels
        ) {
            levelsInfo[_pid][i].levelStaked = CustomMath.min(
                iSum,
                levelsInfo[_pid][i].levelStakingLimit
            );
            iSum = iSum.sub(levelsInfo[_pid][i].levelStaked);
        }
    }

    function thresholdConsumedTillLastLevel(
        uint256 _pid,
        uint256 _sequence,
        uint256 _level
    ) public view returns (uint256) {
        uint256 thresholdConsumedValue = 0;

        for (uint256 level = _level; level >= 0; level--) {
            if (_sequence == currentThresholds[_pid][level].sequence) {
                thresholdConsumedValue += currentThresholds[_pid][level].amount;
            } else {
                break;
            }
            if (level == 0) {
                break;
            }
        }

        return thresholdConsumedValue;
    }

    function thresholdMoveInSameBlock(
        uint256 _currentThreshold,
        uint256 _thresholdConsumedTillLastLevel,
        uint256 _total,
        uint256 iGap,
        uint256 _levelStakingLimit
    ) public pure returns (uint256) {
        uint256 _toAdjust = 0;
        if (_currentThreshold != 0) {
            if (_total >= _thresholdConsumedTillLastLevel) {
                if (_total - _thresholdConsumedTillLastLevel >= iGap) {
                    _toAdjust = iGap + _currentThreshold;
                } else {
                    _toAdjust =
                        _currentThreshold +
                        _total -
                        _thresholdConsumedTillLastLevel;
                }
            } else {
                _toAdjust =
                    _currentThreshold +
                    _total -
                    _thresholdConsumedTillLastLevel;
            }
            _toAdjust = CustomMath.min(_toAdjust, _levelStakingLimit);
        }
        return _toAdjust;
    }

    function calculateRemainingGap(
        uint256 _thresholdConsumedTillLastLevel,
        uint256 _currentThreshold,
        uint256 _total,
        uint256 _levelStakingLimit,
        uint256 iGap,
        uint256 _toAdjust
    ) internal pure returns (uint256) {
        if (_currentThreshold == 0) {
            return iGap;
        }

        if (_thresholdConsumedTillLastLevel - _currentThreshold == 0) {
            if (_currentThreshold + iGap <= _total) {
                iGap = 0;
            } else {
                iGap = _currentThreshold + iGap - _total;
            }
        } else {
            iGap = _levelStakingLimit - _toAdjust;
        }
        return iGap;
    }

    function moveThresholdInALoop(
        uint256 _pid,
        uint256 level,
        uint256 iGap
    ) internal {
        uint256 nextSeq = depositInfo[_pid][
            currentThresholds[_pid][level].sequence
        ].nextSequenceID;
        while ((iGap > 0) && (nextSeq > 0)) {
            if (depositInfo[_pid][nextSeq].initialStakedAmount < iGap) {
                iGap -= depositInfo[_pid][nextSeq].initialStakedAmount;
                uint256 nextSeq1 = depositInfo[_pid][nextSeq].nextSequenceID;

                if (nextSeq1 == 0) {
                    currentThresholds[_pid][level].sequence = nextSeq;
                    currentThresholds[_pid][level].amount = getThresholdInfo(
                        _pid,
                        nextSeq
                    )[level];
                    break;
                }
                nextSeq = nextSeq1;
                continue;
            } else if (depositInfo[_pid][nextSeq].initialStakedAmount == iGap) {
                currentThresholds[_pid][level].sequence = nextSeq;
                currentThresholds[_pid][level].amount = depositInfo[_pid][
                    currentThresholds[_pid][level].sequence
                ].initialStakedAmount;
                iGap = 0;
                break;
            } else if (depositInfo[_pid][nextSeq].initialStakedAmount > iGap) {
                currentThresholds[_pid][level].sequence = nextSeq;
                currentThresholds[_pid][level].amount = iGap;
                iGap = 0;
                break;
            }
        }
    }

    function adjustThresholdForLevelUpdate(
        uint256 _poolID,
        uint256 level,
        uint256 iGap,
        bool isIncrease
    ) internal {
        if (isIncrease) {
            Threshold memory ths = currentThresholds[_poolID][level];
            uint256 _thresholdConsumedTillLastLevel = thresholdConsumedTillLastLevel(
                    _poolID,
                    ths.sequence,
                    level
                );
            uint256 _total = depositInfo[_poolID][ths.sequence]
                .initialStakedAmount;
            // calculate how much can be moved in the same block
            uint256 _toAdjust = thresholdMoveInSameBlock(
                ths.amount,
                _thresholdConsumedTillLastLevel,
                _total,
                iGap,
                levelsInfo[_poolID][level].levelStakingLimit
            );
            currentThresholds[_poolID][level].amount = _toAdjust;
            // calculate remaining gap
            iGap = calculateRemainingGap(
                _thresholdConsumedTillLastLevel,
                ths.amount,
                _total,
                levelsInfo[_poolID][level].levelStakingLimit,
                iGap,
                _toAdjust
            );
            moveThresholdInALoop(_poolID, level, iGap);
        }
        //isIncrease == NO
    }

    function adjustThreshold(
        uint256 _pid,
        uint256 _sequence,
        uint256[] memory _sequenceLevels
    ) internal {
        uint256 iGap = 0;
        for (uint256 level = 0; level < (poolInfo[_pid].levels); level++) {
            if (levelsInfo[_pid][level].levelStaked == 0) {
                currentThresholds[_pid][level].amount = 0;
                currentThresholds[_pid][level].sequence = 0;
                continue;
            }
            iGap = _sequenceLevels[level];
            // if there no gap, move on
            if (iGap == 0) {
                continue;
            }
            //casecade the gap to the next level by default
            if (level < (poolInfo[_pid].levels) - 1) {
                _sequenceLevels[level + 1] += _sequenceLevels[level];
            }
            //x
            uint256 _currentThreshold = currentThresholds[_pid][level].amount;

            uint256 _total = depositInfo[_pid][
                currentThresholds[_pid][level].sequence
            ].initialStakedAmount;
            //z
            uint256 _thresholdConsumedTillLastLevel = thresholdConsumedTillLastLevel(
                    _pid,
                    currentThresholds[_pid][level].sequence,
                    level
                );

            //k
            uint256 _toAdjust;
            //if the element is removed now, move on to the net block, else may need to adjust the current block
            uint256 _levelStakingLimit = levelsInfo[_pid][level]
                .levelStakingLimit;
            if (_currentThreshold != 0) {
                _toAdjust = thresholdMoveInSameBlock(
                    _currentThreshold,
                    _thresholdConsumedTillLastLevel,
                    _total,
                    iGap,
                    _levelStakingLimit
                );

                //calculate iGap
                iGap = calculateRemainingGap(
                    _thresholdConsumedTillLastLevel,
                    _currentThreshold,
                    _total,
                    _levelStakingLimit,
                    iGap,
                    _toAdjust
                );
                currentThresholds[_pid][level].amount = _toAdjust;

                if (_toAdjust == levelsInfo[_pid][level].levelStakingLimit) {
                    continue;
                }
            }

            moveThresholdInALoop(_pid, level, iGap);
        }
    }

    function getLevelInfo(uint256 _pid, uint256 _sequenceID)
        internal
        view
        returns (uint256[] memory)
    {
        uint256[] memory returnLevelData = new uint256[](poolInfo[_pid].levels);
        for (uint8 i = 0; i < poolInfo[_pid].levels; i++) {
            returnLevelData[i] = lastUpdatedLevelForDeposits[_pid][_sequenceID][
                i
            ];
        }
        return returnLevelData;
    }

    function updateUserInfoForBlockRemoval(
        uint256 _pid,
        uint256 _sequenceID,
        uint256 _amount,
        uint256 _interest
    ) internal {
        userInfo[msg.sender][_pid].lastAccrued = block.timestamp;

        (uint256 removeIndexForSequences, bool isThere) = getRemoveIndex(
            _sequenceID,
            userInfo[msg.sender][_pid].depositSequences
        );
        if (isThere) {
            // swapping with last element and then pop
            userInfo[msg.sender][_pid].depositSequences[
                removeIndexForSequences
            ] = userInfo[msg.sender][_pid].depositSequences[
                userInfo[msg.sender][_pid].depositSequences.length - 1
            ];
            userInfo[msg.sender][_pid].depositSequences.pop();
        }
        userInfo[msg.sender][_pid].initialStakedAmount = userInfo[msg.sender][
            _pid
        ].initialStakedAmount.sub(_amount);
        userInfo[msg.sender][_pid].totalAmount = userInfo[msg.sender][_pid]
            .totalAmount
            .sub(_amount);
        userInfo[msg.sender][_pid].totalAccrued = userInfo[msg.sender][_pid]
            .totalAccrued
            .add(_interest);
        userInfo[msg.sender][_pid].totalClaimedCoin = userInfo[msg.sender][_pid]
            .totalAccrued;
        userInfo[msg.sender][_pid].lastAccrued = block.timestamp;
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

    function withdraw(uint256 _pid, uint256 _amount) external {
        uint256[] memory availableSequence = userInfo[msg.sender][_pid]
            .depositSequences;
        uint256 remainingAmount = _amount;
        uint256 _claimAmount = 0;
        uint256 _exactAmount = 0;
        uint256 _pending = 0;
        for (uint256 i = (availableSequence.length - 1); i >= 0; i--) {
            DepositInfo storage _deposit = depositInfo[_pid][
                availableSequence[i]
            ];
            uint256 processAmount = 0;

            if (remainingAmount > _deposit.stakedAmount) {
                processAmount = _deposit.stakedAmount;
                remainingAmount = remainingAmount.sub(processAmount);
            } else {
                processAmount = remainingAmount;
                remainingAmount = 0;
            }

            (
                uint256 pendingForSequence,
                uint256 exactAmountForSequence,
                uint256 claimAmountForSequence
            ) = withdrawBySequence(
                    _pid,
                    availableSequence[i],
                    processAmount,
                    true
                );
            _pending = _pending.add(pendingForSequence);
            _exactAmount = _exactAmount.add(exactAmountForSequence);
            _claimAmount = _claimAmount.add(claimAmountForSequence);

            if (remainingAmount == 0 || i == 0) {
                break;
            }
        }

        requestedClaimInfo[msg.sender][_pid].push(
            RequestedClaimInfo({
                claimId: requestedClaimIdIncrementer.current(),
                claimTime: block.timestamp + withdrawTime,
                depositAmount: _exactAmount,
                claimAmount: _claimAmount,
                claimInterest: _pending
            })
        );

        requestedClaimIdIncrementer.increment();
    }

    function withdrawBySequence(
        uint256 _pid,
        uint256 _sequenceID,
        uint256 _amount,
        bool isInternal
    )
        public
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        address _sender = msg.sender;
        //        Validate
        //        amount should not be greater than sequence amount
        PoolInfo storage pool = poolInfo[_pid];
        // UserInfo storage user = userInfo[_sender][_pid];
        DepositInfo storage _deposit = depositInfo[_pid][_sequenceID];

        require(_deposit.stakedAmount >= _amount, "Withdrawal: Invalid");
        require(_deposit.inactive == 0, "Deposit has been withdrawn already");

        //        set data:
        //        1. calculate interest
        uint256 _pending = getGeneratedRewardForSequence(
            _pid,
            _sequenceID,
            _deposit.stakedAmount,
            _deposit.lastUpdated,
            block.timestamp
        );
        //        1b  Get current threshold info
        // Threshold[] memory ths;

        uint256[] memory sequenceLevels = getThresholdInfo(_pid, _sequenceID);
        //        2. remove the block
        removeDepositBlockAndUpdatePool(_pid, _sequenceID, _pending);
        // 2b. Update levelinfo
        updateLevelForBlockRemoval(_pid, sequenceLevels, false);
        updateUserInfoForBlockRemoval(
            _pid,
            _sequenceID,
            _deposit.stakedAmount,
            _pending
        );
        if (_amount > 0) {
            adjustThreshold(_pid, _sequenceID, sequenceLevels);
        }
        if (_deposit.stakedAmount - _amount > 0) {
            uint256 depositAmount = _deposit.stakedAmount.sub(_amount);
            depositInternal(
                _pid,
                ((depositAmount).mul(pool.eInvestCoinValue)).div(
                    _deposit.iCoinValue
                ),
                true
            );
        }
        uint256 investCoinValueAmount = _amount.mul(pool.eInvestCoinValue);

        if (!isInternal) {
            // Making withdraw request entry
            requestedClaimInfo[_sender][_pid].push(
                RequestedClaimInfo({
                    claimId: requestedClaimIdIncrementer.current(),
                    claimTime: block.timestamp + withdrawTime,
                    claimAmount: investCoinValueAmount.div(_deposit.iCoinValue),
                    depositAmount: _amount,
                    claimInterest: _pending
                })
            );
            requestedClaimIdIncrementer.increment();
        }

        emit Withdraw(_sender, _pid, _amount);
        if (isInternal) {
            return (
                _pending,
                _amount,
                investCoinValueAmount.div(_deposit.iCoinValue)
            );
        } else {
            return (0, 0, 0);
        }
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) external {
        UserInfo storage user = userInfo[msg.sender][_pid];
        uint256 _amount = user.totalAmount;
        user.totalAmount = 0;
        IERC20(poolInfo[_pid].depositToken).safeTransfer(msg.sender, _amount);
    }

    function setOperator(address _operator) external onlyOperator {
        operator = _operator;
    }

    function setTransferOutOperator(address _operator)
        external
        onlyTransferOutOperator
    {
        transferOutOperator = _operator;
    }

    // @notice Sets the pool end time to extend the gen pools if required.
    function setPoolEndTime(uint256 _poolID, uint256 _pool_end_time)
        external
        onlyOperator
    {
        poolInfo[_poolID].poolEndTime = _pool_end_time;
    }

    function setPoolStartTime(uint256 _poolID, uint256 _pool_start_time)
        external
        onlyOperator
    {
        poolInfo[_poolID].poolStartTime = _pool_start_time;
    }

    function setEInvestValue(uint256 _poolID, uint256 _eInvestCoinValue)
        external
        onlyOperator
    {
        poolInfo[_poolID].eInvestCoinValue = _eInvestCoinValue;
    }

    // @notice imp. only use this function to replenish rewards
    function replenishReward(uint256 _poolID, uint256 _value)
        external
        onlyOperator
    {
        poolInfo[_poolID].rewardsBalance += _value;

        IERC20(poolInfo[_poolID].rewardToken).safeTransferFrom(
            msg.sender,
            address(this),
            _value
        );
    }

    // @notice can only transfer out the rewards balance and not user fund.
    function transferOutECoin(
        uint256 _poolID,
        address _to,
        uint256 _value
    ) external onlyTransferOutOperator {
        require(
            _value <= poolInfo[_poolID].rewardsBalance,
            "Invalid value"
            // "Trying to transfer out more miner than available"
        );
        poolInfo[_poolID].rewardsBalance -= _value;
        IERC20(poolInfo[_poolID].rewardToken).safeTransfer(_to, _value);
    }

    // @notice sets a pool's isStarted to true and increments total allocated points
    function startPool(uint256 _pid) public onlyOperator {
        PoolInfo storage pool = poolInfo[_pid];
        if (!pool.isStarted) {
            pool.isStarted = true;
        }
    }

    // View function to see rewards balance.
    function getRewardsBalance(uint256 _poolID)
        external
        view
        returns (uint256)
    {
        return poolInfo[_poolID].rewardsBalance;
    }

    function getLatestRate(uint256 _pid, uint256 _levelID)
        external
        view
        returns (uint256)
    {
        return
            rateInfo[_pid][_levelID][rateInfo[_pid][_levelID].length - 1].rate;
    }

    //modify treasury address
    function setTreasury(uint256 _pId, address _treasury) external onlyOperator {
        treasury[_pId] = _treasury;
    }

    function setWithdrawTime(uint256 _timeSpan) external onlyOperator {
        withdrawTime = _timeSpan;
    }

    function claimRequestedWithdrawal(uint256 _pid, uint256 _withdrawalId)
        external
    {
        RequestedClaimInfo memory requestedWithdrawInfo = RequestedClaimInfo({
            claimId: 0,
            claimTime: 0,
            depositAmount: 0,
            claimAmount: 0,
            claimInterest: 0
        });
        //Fetching Clear the entry from the requestedClaimInfo
        bool isThere = false;
        uint256 clearIndex = 0;
        for (
            uint256 i = 0;
            i < requestedClaimInfo[msg.sender][_pid].length;
            i++
        ) {
            if (
                _withdrawalId == requestedClaimInfo[msg.sender][_pid][i].claimId
            ) {
                isThere = true;
                clearIndex = i;
                requestedWithdrawInfo = requestedClaimInfo[msg.sender][_pid][i];
                break;
            }
        }

        require(isThere, "Withdrawal is invalid");

        require(
            requestedWithdrawInfo.claimTime <= block.timestamp,
            "Withdrawal not yet available"
        );

        require(poolInfo[_pid].rewardsBalance >= requestedWithdrawInfo.claimAmount.add(requestedWithdrawInfo.claimInterest), "Insufficient Balance");

        if (isThere) {
            // swapping with last element and then pop
            requestedClaimInfo[msg.sender][_pid][
                clearIndex
            ] = requestedClaimInfo[msg.sender][_pid][
                requestedClaimInfo[msg.sender][_pid].length - 1
            ];
            requestedClaimInfo[msg.sender][_pid].pop();
        }

        poolInfo[_pid].rewardsBalance = poolInfo[_pid].rewardsBalance.sub(requestedWithdrawInfo.claimAmount.add(requestedWithdrawInfo.claimInterest));

        uint256 taxedReductedAmount = getTaxedAmount(
            false,
            _pid,
            (requestedWithdrawInfo.claimInterest)
        );

        IERC20(poolInfo[_pid].depositToken).safeTransfer(
            msg.sender,
            requestedWithdrawInfo.claimAmount.add(taxedReductedAmount)
        );
    }

    function fetchConsolidatedDetails(uint256 _poolID, address _sender)
        external
        view
        returns (uint256, uint256)
    {
        UserInfo storage userData = userInfo[_sender][_poolID];

        // DepositInfo memory depositData = depositInfo[_poolID][_sender];
        return (userData.totalAmount, userData.totalAccrued);
    }

    function updateTaxRates(
        uint256 _poolID,
        uint256 _depositDev,
        uint256 _depositProtocal,
        uint256 _withdrawDev,
        uint256 _withdrawProtocal
    ) external onlyOperator {
        uint256[] memory _taxRates = new uint256[](4);
        _taxRates[0] = _depositDev;
        _taxRates[1] = _depositProtocal;
        _taxRates[2] = _withdrawDev;
        _taxRates[3] = _withdrawProtocal;
        poolInfo[_poolID].taxRates = _taxRates;
    }

    function updateTaxAddress(
        address _devTaxAddress,
        address _protocalTaxAddress
    ) external onlyOperator {
        address[] memory _taxAddress = new address[](2);
        _taxAddress[0] = _devTaxAddress;
        _taxAddress[1] = _protocalTaxAddress;
        taxAddress = _taxAddress;
    }

    function getTaxedAmount(
        bool isDeposit,
        uint256 _poolID,
        uint256 _amount
    ) internal returns (uint256) {
        uint256[] memory _taxRates = poolInfo[_poolID].taxRates;
        uint256 _calculatedAmount = 0;
        if (isDeposit) {
            uint256 devTaxed = ((SafeMath.mul(_amount, _taxRates[0])).div(100))
                .div(1000000000000000000);

            uint256 protocalTaxed = (
                (SafeMath.mul(_amount, _taxRates[1])).div(100)
            ).div(1000000000000000000);
            _calculatedAmount = SafeMath.sub(
                _amount,
                SafeMath.add(devTaxed, protocalTaxed)
            );

            IERC20(poolInfo[_poolID].depositToken).safeTransfer(
                taxAddress[0],
                devTaxed
            );
            IERC20(poolInfo[_poolID].depositToken).safeTransfer(
                taxAddress[1],
                protocalTaxed
            );
        } else {
            uint256 devTaxed = ((SafeMath.mul(_amount, _taxRates[2])).div(100))
                .div(1000000000000000000);

            uint256 protocalTaxed = (
                (SafeMath.mul(_amount, _taxRates[3])).div(100)
            ).div(1000000000000000000);
            _calculatedAmount = SafeMath.sub(
                _amount,
                SafeMath.add(devTaxed, protocalTaxed)
            );

            IERC20(poolInfo[_poolID].rewardToken).safeTransfer(
                taxAddress[0],
                devTaxed
            );
            IERC20(poolInfo[_poolID].rewardToken).safeTransfer(
                taxAddress[1],
                protocalTaxed
            );
        }
        return _calculatedAmount;
    }

    function updateLastUpdatedLevelForDeposits(uint256 _poolID, address _user)
        external
    {
        UserInfo storage userData = userInfo[_user][_poolID];
        for (uint256 i = 0; i < userData.depositSequences.length; i++) {
            uint256 sequenceID = userData.depositSequences[i];
            uint256 currentDepositAmount = depositInfo[_poolID][sequenceID]
                .stakedAmount;
            for (uint8 level = 0; level < poolInfo[_poolID].levels; level++) {
                //Cleaning the available data
                lastUpdatedLevelForDeposits[_poolID][sequenceID][level] = 0;
                if (currentThresholds[_poolID][level].sequence > sequenceID) {
                    lastUpdatedLevelForDeposits[_poolID][sequenceID][
                        level
                    ] = currentDepositAmount;
                    currentDepositAmount = 0;
                    // break;
                    continue;
                } else if (
                    currentThresholds[_poolID][level].sequence == sequenceID
                ) {
                    lastUpdatedLevelForDeposits[_poolID][sequenceID][
                        level
                    ] = currentThresholds[_poolID][level].amount;
                    if (
                        currentDepositAmount <=
                        currentThresholds[_poolID][level].amount
                    ) {
                        currentDepositAmount = 0;
                        // break;
                        continue;
                    } else {
                        currentDepositAmount = SafeMath.sub(
                            currentDepositAmount,
                            currentThresholds[_poolID][level].amount
                        );
                        continue;
                    }
                } else if (
                    currentThresholds[_poolID][level].sequence < sequenceID
                ) {
                    lastUpdatedLevelForDeposits[_poolID][sequenceID][level] = 0;
                    continue;
                }
                // }
            }
        }
    }

    function addPreApprovedUser(address[] memory userAddress)
        external
        onlyOperator
    {
        for (uint256 i = 0; i < userAddress.length; i++) {
            if (!preApprovedUsers[userAddress[i]]) {
                preApprovedUsers[userAddress[i]] = true;
            }
        }
    }

    function pendingShare(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        UserInfo storage user = userInfo[_user][_pid];
        uint256 _pendings = 0;
        for (uint256 i = 0; i < user.depositSequences.length; i++) {
            DepositInfo storage _deposit = depositInfo[_pid][
                user.depositSequences[i]
            ];
            _pendings = _pendings.add(
                getGeneratedRewardForSequence(
                    _pid,
                    user.depositSequences[i],
                    _deposit.stakedAmount,
                    _deposit.lastUpdated,
                    block.timestamp
                )
            );
        }
        return _pendings;
    }

    function fetchWithdrawLength(uint256 _pid, address user)
        external
        view
        returns (uint256)
    {
        return requestedClaimInfo[user][_pid].length;
    }

    function fetchUserLevelStatus(uint256 _pid, address _user)
        external
        view
        returns (uint256[] memory)
    {
        UserInfo storage userData = userInfo[_user][_pid];
        uint256[] memory finalLevelUpdateList = new uint256[](
            userData.depositSequences.length
        );

        uint8 counter = 0;

        for (uint256 i = 0; i < userData.depositSequences.length; i++) {
            uint256[] memory currentLevelUpdatedArr = new uint256[](poolInfo[_pid].levels);
            uint256 sequenceID = userData.depositSequences[i];

            currentLevelUpdatedArr = getThresholdInfo(_pid,sequenceID);
            for (uint8 k = 0; k < currentLevelUpdatedArr.length; k++) {
                if(currentLevelUpdatedArr[k] != lastUpdatedLevelForDeposits[_pid][sequenceID][k]){
                    finalLevelUpdateList[counter] = sequenceID;
                    counter++;
                    break;
                }
            }
        }
        return finalLevelUpdateList;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

import "IERC20.sol";
import "SafeMath.sol";
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
    using SafeMath for uint256;
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
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        require(b > 0, errorMessage);
        return a / b;
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
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

import "SafeMath.sol";

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the {SafeMath}
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

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
        // The {SafeMath} overflow check can be skipped here, see the comment at the top
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}