// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "AllContractForDeployment.sol";
import "AccessControl.sol";

contract DataContractQF is AccessControl {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    // address public operator;
    // address public transferOutOperator;
    //poolID => seqID => list of levels
    mapping(uint256 => mapping(uint256 => mapping(uint8 => uint256)))
        public lastUpdatedLevelForDeposits;
    //pool-> seq -> DepositInfo
    mapping(uint256 => mapping(uint256 => QueueFinanceLib.DepositInfo))
        public depositInfo;
    // wallet -> poolId
    mapping(address => mapping(uint256 => QueueFinanceLib.UserInfo))
        public userInfo;
    // poolID -> LevelID-> Rate
    QueueFinanceLib.RateInfoStruct[][][] public rateInfo;
    //Pool -> levels
    mapping(uint256 => mapping(uint256 => QueueFinanceLib.LevelInfo))
        public levelsInfo;
    // // Info of each pool.
    QueueFinanceLib.PoolInfo[] public poolInfo;

    mapping(uint256 => bool) poolIsPrivate;

    mapping(address => bool) preApprovedUsers;

    mapping(uint256 => Counters.Counter) public currentSequenceIncrement;
    // // Info of each pool.
    mapping(uint256 => address) public treasury;
    // pool ->levels -> Threshold
    mapping(uint256 => mapping(uint256 => QueueFinanceLib.Threshold))
        public currentThresholds;
    uint256 public withdrawTime = 86400; // 24 hours
    mapping(address => mapping(uint256 => QueueFinanceLib.RequestedClaimInfo[]))
        public requestedClaimInfo;
    Counters.Counter requestedClaimIdIncrementer;
    mapping(uint256 => uint256[]) public taxRates;

    mapping(uint256 => uint256) public poolBalance;

    // address[] public taxAddress;
    bool public initialized;
    mapping(uint256 => address[]) public taxAddress;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant ACCESS_ROLE = keccak256("ACCESS_ROLE");

    // Initialize
    function initialize(address _owner) public {
        require(!initialized, "Already Initialized");
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(ADMIN_ROLE, _owner);
        _setupRole(ACCESS_ROLE, _owner);
        initialized = true;
    }

    //=========================Roles=======================================
    function checkRole(address account, bytes32 role) public view {
        require(hasRole(role, account), "Role Does Not Exist");
    }

    function checkEitherACCESSorADMIN(address account) public view {
        require(
            (hasRole(ADMIN_ROLE, account) ||
                hasRole(ACCESS_ROLE, account) ||
                hasRole(DEFAULT_ADMIN_ROLE, account)),
            "Neither ADMIN nor ACCESS"
        );
    }

    function giveRole(address wallet, uint256 _roleId) public {
        require(_roleId >= 0 && _roleId <= 2, "Invalid roleId");
        checkRole(msg.sender, DEFAULT_ADMIN_ROLE);
        bytes32 _role;
        if (_roleId == 0) {
            _role = ADMIN_ROLE;
        } else if (_roleId == 1) {
            _role = ACCESS_ROLE;
        }
        grantRole(_role, wallet);
    }

    function revokeRole(address wallet, uint256 _roleId) public {
        require(_roleId >= 0 && _roleId <= 2, "Invalid roleId");
        checkRole(msg.sender, DEFAULT_ADMIN_ROLE);
        bytes32 _role;
        if (_roleId == 0) {
            _role = ADMIN_ROLE;
        } else if (_roleId == 1) {
            _role = ACCESS_ROLE;
        }
        revokeRole(_role, wallet);
    }

    function transferRole(
        address wallet,
        address oldWallet,
        uint256 _roleId
    ) public {
        require(_roleId >= 0 && _roleId <= 2, "Invalid roleId");
        checkRole(msg.sender, DEFAULT_ADMIN_ROLE);
        bytes32 _role;
        if (_roleId == 0) {
            _role = ADMIN_ROLE;
        } else if (_roleId == 1) {
            _role = ACCESS_ROLE;
        }
        grantRole(_role, wallet);
        revokeRole(_role, oldWallet);
    }

    function renounceOwnership() public {
        checkRole(msg.sender, DEFAULT_ADMIN_ROLE);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function getPoolInfo(uint256 _poolId)
        public
        view
        returns (QueueFinanceLib.PoolInfo memory)
    {
        return poolInfo[_poolId];
    }

    function addPool(QueueFinanceLib.PoolInfo memory poolData) public {
        checkRole(msg.sender, ADMIN_ROLE);
        poolInfo.push(poolData);
    }

    function getPoolInfoLength() public view returns (uint256) {
        return poolInfo.length;
    }

    function setLastUpdatedLevelForDeposits(
        uint256 _poolID,
        uint256 _seqID,
        uint8 _levelID,
        uint256 _amount
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        lastUpdatedLevelForDeposits[_poolID][_seqID][_levelID] = _amount;
    }

    // function setPoolIsPrivate(uint256 _poolID, bool _isPrivate) public {
    //     checkRole(msg.sender, ADMIN_ROLE);
    //     poolIsPrivate[_poolID] = _isPrivate;
    // }

    function setLastUpdatedLevelsForDeposits(
        uint256 _poolID,
        uint256 _seqID,
        uint256[] memory _lastUpdatedLevelAmounts
    ) public {
        checkEitherACCESSorADMIN(msg.sender);
        for (uint8 i = 0; i < poolInfo[_poolID].levels; i++) {
            lastUpdatedLevelForDeposits[_poolID][_seqID][
                i
            ] = _lastUpdatedLevelAmounts[i];
        }
    }

    function setLastUpdatedLevelsForSequences(uint256 _poolID, QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[] memory _lastUpdatedLevels, QueueFinanceLib.LastUpdatedLevelsPendings[] memory _lastUpdatedLevelsPendings) external {
        checkEitherACCESSorADMIN(msg.sender);
        for (uint256 i = 0; i < _lastUpdatedLevels.length; i++) {
            setLastUpdatedLevelsForDeposits(_poolID, _lastUpdatedLevels[i].sequenceId, _lastUpdatedLevels[i].lastUpdatedLevelsForDeposits);
        }
        for (uint256 i = 0; i < _lastUpdatedLevelsPendings.length; i++) {
            depositInfo[_poolID][_lastUpdatedLevelsPendings[i].sequenceId].accuredCoin = depositInfo[_poolID][_lastUpdatedLevelsPendings[i].sequenceId].accuredCoin.add(_lastUpdatedLevelsPendings[i].accruedCoin);
            depositInfo[_poolID][_lastUpdatedLevelsPendings[i].sequenceId].lastUpdated = block.timestamp;
        }
    }

    function setDepositInfo(
        uint256 _poolID,
        uint256 _seqID,
        QueueFinanceLib.DepositInfo memory _depositInfo
    ) public {
        checkEitherACCESSorADMIN(msg.sender);
        depositInfo[_poolID][_seqID] = _depositInfo;
    }

    function getUserInfo(address _sender, uint256 _poolId)
        public
        view
        returns (QueueFinanceLib.UserInfo memory)
    {
        return userInfo[_sender][_poolId];
    }

    function setUserInfoForDeposit(
        address _sender,
        uint256 _poolID,
        uint256 _newSeqId,
        QueueFinanceLib.UserInfo memory _userInfo
    ) public {
        checkEitherACCESSorADMIN(msg.sender);
        userInfo[_sender][_poolID] = _userInfo;
        userInfo[_sender][_poolID].depositSequences.push(_newSeqId);
    }

    function setRateInfoStruct(
        uint256 _poolID,
        uint8 _levelID,
        QueueFinanceLib.RateInfoStruct memory _rateInfoStruct
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        rateInfo[_poolID][_levelID].push(_rateInfoStruct);
    }

    function pushWholeRateInfoStruct(
        QueueFinanceLib.RateInfoStruct memory _rateInfoStruct
    ) external {
        checkRole(msg.sender, ADMIN_ROLE);
        rateInfo.push().push().push(_rateInfoStruct);
    }

    function pushRateInfoStruct(
        uint256 _poolID,
        QueueFinanceLib.RateInfoStruct memory _rateInfoStruct
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        rateInfo[_poolID].push().push(_rateInfoStruct);
    }

    function incrementPoolInfoLevels(uint256 _poolId) external {
        checkEitherACCESSorADMIN(msg.sender);
        poolInfo[_poolId].levels++;
    }

    function getRateInfoByPoolID(uint256 _poolId)
        external
        view
        returns (QueueFinanceLib.RateInfoStruct[][] memory _rateInfo)
    {
        return rateInfo[_poolId];
    }

    function setLevelsInfo(
        uint256 _poolID,
        uint8 _levelID,
        QueueFinanceLib.LevelInfo memory _levelsInfo
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        levelsInfo[_poolID][_levelID] = _levelsInfo;
    }

    function setLevelInfo(
        uint256 _pid,
        uint8 _levelId,
        QueueFinanceLib.LevelInfo memory _levelInfo
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        levelsInfo[_pid][_levelId] = _levelInfo;
    }

    function setCurrentThresholdsForTxn(
        uint256 _poolId,
        QueueFinanceLib.Threshold[] memory _threshold
    ) public {
        checkEitherACCESSorADMIN(msg.sender);
        for (uint256 i = 0; i < poolInfo[_poolId].levels; i++) {
            currentThresholds[_poolId][i] = _threshold[i];
        }
    }

    function getAllLevelInfo(uint256 _poolId)
        public
        view
        returns (QueueFinanceLib.LevelInfo[] memory)
    {
        QueueFinanceLib.LevelInfo[]
            memory levelInfoArr = new QueueFinanceLib.LevelInfo[](
                poolInfo[_poolId].levels
            );
        for (uint256 i = 0; i < poolInfo[_poolId].levels; i++) {
            levelInfoArr[i] = levelsInfo[_poolId][i];
        }
        return levelInfoArr;
    }

    function getAllThresholds(uint256 _poolId)
        public
        view
        returns (QueueFinanceLib.Threshold[] memory)
    {
        QueueFinanceLib.Threshold[]
            memory thresholdInfoArr = new QueueFinanceLib.Threshold[](
                poolInfo[_poolId].levels
            );
        for (uint256 i = 0; i < poolInfo[_poolId].levels; i++) {
            thresholdInfoArr[i] = currentThresholds[_poolId][i];
        }
        return thresholdInfoArr;
    }

    function setPoolInfo(
        uint256 _poolID,
        QueueFinanceLib.PoolInfo memory _poolInfo
    ) public {
        checkEitherACCESSorADMIN(msg.sender);
        poolInfo[_poolID] = _poolInfo;
    }

    function doCurrentSequenceIncrement(uint256 _poolID)
        public
        returns (uint256)
    {
        checkEitherACCESSorADMIN(msg.sender);
        currentSequenceIncrement[_poolID].increment();
        return currentSequenceIncrement[_poolID].current();
    }

    function updatePoolBalance(
        uint256 _poolID,
        uint256 _amount,
        bool isIncrease
    ) public {
        checkRole(msg.sender, ACCESS_ROLE);
        if (isIncrease) {
            poolBalance[_poolID] = poolBalance[_poolID].add(_amount);
        } else {
            poolBalance[_poolID] = poolBalance[_poolID].sub(_amount);
        }
    }

    function setCurrentThresholds(
        uint256 _poolID,
        uint256 _levelID,
        QueueFinanceLib.Threshold memory _threshold
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        currentThresholds[_poolID][_levelID] = _threshold;
    }

    function setTaxAddress(
        uint256 _poolId,
        address _devTaxAddress,
        address _protocalTaxAddress,
        address _introducerAddress,
        address _networkAddress
    ) public {
        checkEitherACCESSorADMIN(msg.sender);
        address[] memory _taxAddress = new address[](4);
        _taxAddress[0] = _devTaxAddress;
        _taxAddress[1] = _protocalTaxAddress;
        _taxAddress[2] = _introducerAddress;
        _taxAddress[3] = _networkAddress;
        taxAddress[_poolId] = _taxAddress;
    }

    function getTaxAddress(uint256 _poolId) public view returns (address[] memory) {
        checkEitherACCESSorADMIN(msg.sender);
        return taxAddress[_poolId];
    }
    function getSequenceIdsFromCurrentThreshold(uint256 _poolId)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory sequenceIds = new uint256[](poolInfo[_poolId].levels);
        for (uint256 i = 0; i < poolInfo[_poolId].levels; i++) {
            sequenceIds[i] = currentThresholds[_poolId][i].sequence;
        }
        return sequenceIds;
    }

    function fetchDepositsBasedonSequences(
        uint256 _poolId,
        uint256[] memory _sequenceIds
    ) public view returns (QueueFinanceLib.DepositsBySequence[] memory) {
        QueueFinanceLib.DepositsBySequence[]
            memory depositsInfo = new QueueFinanceLib.DepositsBySequence[](
                _sequenceIds.length
            );

        for (uint256 i = 0; i < _sequenceIds.length; i++) {
            depositsInfo[i] = QueueFinanceLib.DepositsBySequence({
                sequenceId: _sequenceIds[i],
                depositInfo: depositInfo[_poolId][_sequenceIds[i]]
            });
        }

        return depositsInfo;
    }

    function getPoolStartTime(uint256 _poolId) external view returns (uint256) {
        return poolInfo[_poolId].poolStartTime;
    }

    function getLatestRateInfo(uint256 _pid, uint256 _levelID)
        external
        view
        returns (QueueFinanceLib.RateInfoStruct memory)
    {
        return rateInfo[_pid][_levelID][rateInfo[_pid][_levelID].length - 1];
    }

    function getRateInfoLength(uint256 _pid, uint256 _levelID)
        external
        view
        returns (uint256)
    {
        return rateInfo[_pid][_levelID].length;
    }

    function getLatestRateInfoByPosition(
        uint256 _pid,
        uint256 _levelID,
        uint256 _position
    ) external view returns (QueueFinanceLib.RateInfoStruct memory) {
        return rateInfo[_pid][_levelID][_position];
    }

    function pushRateInfo(
        uint256 _pid,
        uint256 _levelID,
        QueueFinanceLib.RateInfoStruct memory _rateInfo
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        rateInfo[_pid][_levelID].push(_rateInfo);
    }

    function setRateInfoByPosition(
        uint256 _pid,
        uint256 _levelID,
        uint256 _position,
        QueueFinanceLib.RateInfoStruct memory _rateInfo
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        rateInfo[_pid][_levelID][_position].timestamp = _rateInfo.timestamp;
        rateInfo[_pid][_levelID][_position].rate = _rateInfo.rate;
    }

    // @notice Sets the pool end time to extend the gen pools if required.
    function setPoolEndTime(uint256 _poolID, uint256 _pool_end_time) external {
        checkRole(msg.sender, ADMIN_ROLE);
        poolInfo[_poolID].poolEndTime = _pool_end_time;
    }

    function setPoolStartTime(uint256 _poolID, uint256 _pool_start_time)
        external
    {
        checkRole(msg.sender, ADMIN_ROLE);
        poolInfo[_poolID].poolStartTime = _pool_start_time;
    }

    function setEInvestValue(uint256 _poolID, uint256 _eInvestCoinValue)
        external
    {
        checkRole(msg.sender, ADMIN_ROLE);
        poolInfo[_poolID].eInvestCoinValue = _eInvestCoinValue;
    }

    function addReplenishReward(uint256 _poolID, uint256 _value) external {
        checkRole(msg.sender, ADMIN_ROLE);
        poolInfo[_poolID].rewardsBalance += _value;
    }

    function getRewardToken(uint256 _poolId) external view returns (IERC20) {
        return poolInfo[_poolId].rewardToken;
    }

    // // @notice sets a pool's isStarted to true and increments total allocated points
    // function startPool(uint256 _pid) public {
    //     checkRole(msg.sender, ADMIN_ROLE);
    //     if (!poolInfo[_pid].isStarted) {
    //         poolInfo[_pid].isStarted = true;
    //     }
    // }

    function setTreasury(uint256 _pId, address _treasury) external {
        checkRole(msg.sender, ADMIN_ROLE);
        treasury[_pId] = _treasury;
    }

    function setWithdrawTime(uint256 _timeSpan) external {
        checkRole(msg.sender, ADMIN_ROLE);
        withdrawTime = _timeSpan;
    }

    function getWithdrawTime() external view returns (uint256) {
        return withdrawTime;
    }

    function setTaxRates(uint256 _poolID, uint256[] memory _taxRates) external {
        checkEitherACCESSorADMIN(msg.sender);
        taxRates[_poolID] = _taxRates;
    }

    function getTaxRates(uint256 _poolID)
        external
        view
        returns (uint256[] memory)
    {
        return taxRates[_poolID];
    }

    function addPreApprovedUser(address[] memory userAddress) external {
        checkEitherACCESSorADMIN(msg.sender);
        for (uint256 i = 0; i < userAddress.length; i++) {
            if (!preApprovedUsers[userAddress[i]]) {
                preApprovedUsers[userAddress[i]] = true;
            }
        }
    }

    function setMaximumStakingAllowed(
        uint256 _pid,
        uint256 _maximumStakingAllowed
    ) external {
        checkRole(msg.sender, ADMIN_ROLE);
        poolInfo[_pid].maximumStakingAllowed = _maximumStakingAllowed;
    }

    function returnDepositSeqList(uint256 _poodID, address _sender)
        external
        view
        returns (uint256[] memory)
    {
        return userInfo[_sender][_poodID].depositSequences;
    }

    function fetchLastUpdatatedLevelsBySequenceIds(
        uint256 _poolID,
        uint256[] memory sequenceIds
    )
        external
        view
        returns (QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[] memory)
    {
        QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[]
            memory LULD = new QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[](
                sequenceIds.length
            );
        for (uint256 i = 0; i < sequenceIds.length; i++) {
            uint256[] memory lastUpdatedLevels = new uint256[](
                poolInfo[_poolID].levels
            );
            for (uint8 j = 0; j < poolInfo[_poolID].levels; j++) {
                lastUpdatedLevels[j] = lastUpdatedLevelForDeposits[_poolID][
                    sequenceIds[i]
                ][j];
            }
            LULD[i] = QueueFinanceLib.FetchLastUpdatedLevelsForDeposits({
                sequenceId: sequenceIds[i],
                lastUpdatedLevelsForDeposits: lastUpdatedLevels
            });
        }
        return LULD;
    }

    function pushRequestedClaimInfo(
        address _sender,
        uint256 _poolId,
        QueueFinanceLib.RequestedClaimInfo memory _requestedClaimInfo
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        requestedClaimInfo[_sender][_poolId].push(_requestedClaimInfo);
        requestedClaimIdIncrementer.increment();
    }

    function getRequestedClaimInfoIncrementer()
        external
        view
        returns (uint256)
    {
        checkEitherACCESSorADMIN(msg.sender);
        return requestedClaimIdIncrementer.current();
    }

    function getPoolIsPrivateForUser(uint256 _pid, address _user) public view returns (bool, bool){
        checkEitherACCESSorADMIN(msg.sender);
        return (poolIsPrivate[_pid], preApprovedUsers[_user]);
    }

    function getDepositBySequenceId(uint256 _poolId, uint256 _seqId)
        external
        view
        returns (QueueFinanceLib.DepositInfo memory)
    {
        return depositInfo[_poolId][_seqId];
    }

    function removeSeqAndUpdateUserInfo(
        uint256 _poolId,
        uint256 _seqId,
        address _sender,
        uint256 _amount,
        uint256 _interest
    ) internal {
        (uint256 removeIndexForSequences, bool isThere) = QueueFinanceLib
            .getRemoveIndex(
                _seqId,
                userInfo[_sender][_poolId].depositSequences
            );
        if (isThere) {
            // swapping with last element and then pop
            userInfo[_sender][_poolId].depositSequences[
                removeIndexForSequences
            ] = userInfo[_sender][_poolId].depositSequences[
                userInfo[_sender][_poolId].depositSequences.length - 1
            ];
            userInfo[_sender][_poolId].depositSequences.pop();
        }

        userInfo[_sender][_poolId].initialStakedAmount = userInfo[_sender][
            _poolId
        ].initialStakedAmount.sub(_amount);
        userInfo[_sender][_poolId].totalAmount = userInfo[_sender][_poolId]
            .totalAmount
            .sub(_amount);
        userInfo[_sender][_poolId].totalAccrued = userInfo[_sender][_poolId]
            .totalAccrued
            .add(_interest);
        userInfo[_sender][_poolId].totalClaimedCoin = userInfo[_sender][_poolId]
            .totalAccrued;
        userInfo[_sender][_poolId].lastAccrued = block.timestamp;
    }

    function updateAddressOnUserInfo(
        uint256 _pid,
        address _sender,
        address _referral
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        
        if (userInfo[_sender][_pid].referral == address(0)) {
            if (_referral == address(0)) {
                _referral = taxAddress[_pid][3];
            }
            userInfo[_sender][_pid].referral = _referral;
        }
    }

    function getWithdrawRequestedClaimInfo(address _sender, uint256 _pid)
        external
        view
        returns (QueueFinanceLib.RequestedClaimInfo[] memory)
    {
        return requestedClaimInfo[_sender][_pid];
    }

    function fetchWithdrawLength(uint256 _pid, address user)
        external
        view
        returns (uint256)
    {
        return requestedClaimInfo[user][_pid].length;
    }

    function swapAndPopForWithdrawal(
        uint256 _pid,
        address user,
        uint256 clearIndex
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        //  swapping with last element and then pop
        requestedClaimInfo[user][_pid][clearIndex] = requestedClaimInfo[user][
            _pid
        ][requestedClaimInfo[user][_pid].length - 1];
        requestedClaimInfo[user][_pid].pop();
    }

    function doTransfer(
        uint256 amount,
        address to,
        IERC20 depositToken
    ) external {
        checkEitherACCESSorADMIN(msg.sender);
        IERC20(depositToken).safeTransfer(to, amount);
    }
    function addDepositDetailsToDataContract(
        QueueFinanceLib.AddDepositModule memory _addDepositData
    ) public {
        checkRole(msg.sender, ACCESS_ROLE);
        poolInfo[_addDepositData.addDepositData.poolId]
            .totalStaked = _addDepositData.addDepositData.poolTotalStaked;

        poolInfo[_addDepositData.addDepositData.poolId]
            .lastActiveSequence = _addDepositData
            .addDepositData
            .poolLastActiveSequence;
        poolInfo[_addDepositData.addDepositData.poolId]
            .currentSequence = _addDepositData.addDepositData.seqId;

        depositInfo[_addDepositData.addDepositData.poolId][
            _addDepositData.addDepositData1.updateDepositInfo.sequenceId
        ] = _addDepositData.addDepositData1.updateDepositInfo.depositInfo;
        
        depositInfo[_addDepositData.addDepositData.poolId][
            _addDepositData.addDepositData.prevSeqId
        ].nextSequenceID = _addDepositData.addDepositData.seqId;

        userInfo[_addDepositData.addDepositData.sender][
            _addDepositData.addDepositData.poolId
        ].initialStakedAmount = userInfo[_addDepositData.addDepositData.sender][
            _addDepositData.addDepositData.poolId
        ].initialStakedAmount.add(
                _addDepositData
                    .addDepositData1
                    .updateDepositInfo
                    .depositInfo
                    .stakedAmount
            );
        userInfo[_addDepositData.addDepositData.sender][
            _addDepositData.addDepositData.poolId
        ].totalAmount = userInfo[_addDepositData.addDepositData.sender][
            _addDepositData.addDepositData.poolId
        ].totalAmount.add(
                _addDepositData
                    .addDepositData1
                    .updateDepositInfo
                    .depositInfo
                    .stakedAmount
            );
        userInfo[_addDepositData.addDepositData.sender][
            _addDepositData.addDepositData.poolId
        ].lastAccrued = _addDepositData.addDepositData.blockTime;
        userInfo[_addDepositData.addDepositData.sender][
            _addDepositData.addDepositData.poolId
        ].depositSequences.push(_addDepositData.addDepositData.seqId);
        
        for (
            uint8 i = 0;
            i < _addDepositData.addDepositData1.levelsAffected.length;
            i++
        ) {
            lastUpdatedLevelForDeposits[_addDepositData.addDepositData.poolId][
                _addDepositData.addDepositData.seqId
            ][
                _addDepositData.addDepositData1.levelsAffected[i]
            ] = _addDepositData.addDepositData1.updatedLevelsForDeposit[
                _addDepositData.addDepositData1.levelsAffected[i]
            ];

            currentThresholds[_addDepositData.addDepositData.poolId][
                _addDepositData.addDepositData1.levelsAffected[i]
            ] = _addDepositData.addDepositData1.threshold[
                _addDepositData.addDepositData1.levelsAffected[i]
            ];
            levelsInfo[_addDepositData.addDepositData.poolId][
                _addDepositData.addDepositData1.levelsAffected[i]
            ] = _addDepositData.addDepositData1.levelsInfo[
                _addDepositData.addDepositData1.levelsAffected[i]
            ];
            currentThresholds[_addDepositData.addDepositData.poolId][
                _addDepositData.addDepositData1.levelsAffected[i]
            ] = _addDepositData.addDepositData1.threshold[
                _addDepositData.addDepositData1.levelsAffected[i]
            ];
        }
    }

    function updateWithDrawDetails(
        QueueFinanceLib.UpdateWithdrawDataInALoop memory _withdrawData
    ) external {
        checkRole(msg.sender, ACCESS_ROLE);
         QueueFinanceLib.DepositInfo memory _currentDeposit = depositInfo[
            _withdrawData.poolId
        ][_withdrawData.currSeqId];


         removeSeqAndUpdateUserInfo(
            _withdrawData.poolId,
            _withdrawData.currSeqId,
            _withdrawData.user,
            _currentDeposit.stakedAmount,
            _withdrawData.interest
        );

        depositInfo[_withdrawData.poolId][_withdrawData.curDepositPrevSeqId]
            .nextSequenceID = _withdrawData.depositPreviousNextSequenceID;

       
        if (_currentDeposit.nextSequenceID > _withdrawData.currSeqId) {
            depositInfo[_withdrawData.poolId][_withdrawData.curDepositNextSeqId]
                .previousSequenceID = _withdrawData
                .depositNextPreviousSequenceID;
        }

        _currentDeposit.accuredCoin += _withdrawData.interest;
        _currentDeposit.claimedCoin = _currentDeposit.accuredCoin;
        _currentDeposit.lastUpdated = block.timestamp;

        poolInfo[_withdrawData.poolId].totalStaked = poolInfo[
            _withdrawData.poolId
        ].totalStaked.sub(_currentDeposit.stakedAmount);

        if (
            _withdrawData.currSeqId ==
            poolInfo[_withdrawData.poolId].lastActiveSequence
        ) {
            poolInfo[_withdrawData.poolId].lastActiveSequence = _currentDeposit
                .previousSequenceID;
        }

        _currentDeposit.nextSequenceID = 0;
        _currentDeposit.previousSequenceID = 0;
        _currentDeposit.inactive = 1;

        depositInfo[_withdrawData.poolId][
            _withdrawData.currSeqId
        ] = _currentDeposit;

        for (uint256 i = 0; i < poolInfo[_withdrawData.poolId].levels; i++) {
            currentThresholds[_withdrawData.poolId][i] = _withdrawData.thresholds[i];
            levelsInfo[_withdrawData.poolId][i] = _withdrawData.levelsInfo[i];
        }

       
    }
}

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for CountersIDataContractQF.Counter;`
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

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// File: @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: library/QueueFinanceLib.sol


pragma solidity ^0.8.4;



library QueueFinanceLib {
    using SafeMath for uint256;

    struct Level {
        uint256 amount;
        uint256 level; // 0 is the highest level; n is the lowest level
    }

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

    struct UserInfo {
        uint256 initialStakedAmount;
        uint256 totalAmount; // How many  tokens the user has provided.
        uint256 totalAccrued; // Interest accrued till date.
        uint256 totalClaimedCoin; // Interest claimed till date
        uint256 lastAccrued; // Last date when the interest was claimed
        uint256[] depositSequences;
        address referral;
    }

    struct RateInfoStruct {
        uint256 timestamp;
        uint256 rate;
    }

    struct LevelInfo {
        uint256 levelStakingLimit;
        uint256 levelStaked;
    }

    struct PoolInfo {
        // bytes32 name; //Pool name
        uint256 totalStaked; //
        uint256 eInvestCoinValue;
        IERC20 depositToken; // Address of investment token contract.
        IERC20 rewardToken; // Address of reward token contract.
        bool isStarted;
        uint256 maximumStakingAllowed;
        uint256 currentSequence;
        // The time when miner mining starts.
        uint256 poolStartTime;
        // // The time when miner mining ends.
        uint256 poolEndTime;
        uint256 rewardsBalance; // = 0;
        uint256 levels;
        uint256 lastActiveSequence;
        uint256[] taxRates;
    }

    struct Threshold {
        uint256 sequence;
        uint256 amount;
    }

    struct RequestedClaimInfo {
        uint256 claimId;
        uint256 claimTime;
        uint256 claimAmount;
        uint256 depositAmount;
        uint256 claimInterest;
        uint256[] sequenceIds;
    }

    //===========================Structures for Deposits===========================
    struct AddDepositInfo {
        uint256 sequenceId;
        DepositInfo depositInfo;
    }

    struct AllDepositData {
        PoolInfo poolInfo;
        uint256 sequenceId;
        AddDepositInfo depositInfo;
        LevelInfo[] levelInfo;
        UserInfo userInfo;
        Threshold[] thresholdInfo;
    }

    struct AddDepositData {
        uint256 poolId;
        uint256 seqId;
        address sender;
        uint256 prevSeqId;
        uint256 poolTotalStaked;
        uint256 poolLastActiveSequence;
        uint256 blockTime;
    }

    struct AddDepositData1 {
        uint8[] levelsAffected;
        QueueFinanceLib.AddDepositInfo updateDepositInfo;
        uint256[] updatedLevelsForDeposit;
        QueueFinanceLib.LevelInfo[] levelsInfo;
        QueueFinanceLib.Threshold[] threshold;
    }

    struct AddDepositModule {
        AddDepositData addDepositData;
        AddDepositData1 addDepositData1;
    }

    //===========================*Ended for Deposits*===========================

    //===========================Structures for Admin===========================

    struct AddLevelData {
        uint256 poolId;
        uint8 levelId;
        LevelInfo levelInfo;
        RateInfoStruct rateInfo;
        Threshold threshold;
    }

    struct DepositsBySequence {
        uint256 sequenceId;
        DepositInfo depositInfo;
    }

    struct FetchUpdateLevelData {
        LevelInfo[] levelsInfo;
        Threshold[] thresholds;
        DepositsBySequence[] depositsInfo;
    }

    struct DepositDetailsForUser{
        DepositInfo depositInfo;
        uint256[] lastUpdateLevelsForDeposit;
        uint256 seqId;
    }
    //===========================*Ended for Admin*===========================

    //===========================*Structures for withdraw*===========================
    struct FetchLastUpdatedLevelsForDeposits {
        uint256 sequenceId;
        uint256[] lastUpdatedLevelsForDeposits;
    }

    struct LastUpdatedLevelsPendings {
        uint256 sequenceId;
        uint256 accruedCoin;
    }

    struct FetchWithdrawData {
        // DepositsBySequence[] depositsByThresholdId;
        DepositsBySequence[] depositsInfo;
        PoolInfo poolInfo;
        FetchLastUpdatedLevelsForDeposits[] lastUpdatedLevelsForDeposit;
        RateInfoStruct[][] rateInfo;
        Threshold[] threshold;
        uint256 withdrawTime;
        uint256 requestedClaimInfoIncrementer;
        LevelInfo[] levelInfo;
        // UserInfo userInfo;
    }


    struct UpdateWithdrawDataInALoop {
        uint256 poolId;
        uint256 currSeqId;
        uint256 depositPreviousNextSequenceID;
        uint256 depositNextPreviousSequenceID;
        uint256 curDepositPrevSeqId;
        uint256 curDepositNextSeqId;
        uint256 interest;
        QueueFinanceLib.Threshold[] thresholds;
        QueueFinanceLib.LevelInfo[] levelsInfo;
        address user;
    }

    //===========================*Ended for withdraw*================================

    function min(uint256 a, uint256 b) public pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) public pure returns (uint256) {
        return a > b ? a : b;
    }

    function pickDepositBySequenceId(
        DepositsBySequence[] memory deposits,
        uint256 _seqId
    ) public pure returns (DepositInfo memory) {
        for (uint256 i = 0; i < deposits.length; i++) {
            if (deposits[i].sequenceId == _seqId) {
                return deposits[i].depositInfo;
            }
        }
        revert("Invalid Deposit value");
    }

    function pickLastUpdatedLevelsBySequenceId(
        FetchLastUpdatedLevelsForDeposits[] memory _arrData,
        uint256 _seqId
    ) public pure returns (uint256[] memory) {
        for (uint256 i = 0; i < _arrData.length; i++) {
            if (_arrData[i].sequenceId == _seqId) {
                return _arrData[i].lastUpdatedLevelsForDeposits;
            }
        }
        revert("Invalid Data");
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
}

// File: interfaces/IDataContractQF.sol


pragma solidity ^0.8.4;




interface IDataContractQF {
    //poolID => seqID => list of levels
    function lastUpdatedLevelForDeposits(
        uint256 _poolID,
        uint256 seqID,
        uint8 levelID
    ) external view returns (uint256);

    //pool-> seq -> DepositInfo
    function depositInfo(uint256 _poolID, uint256 seqID)
        external
        view
        returns (QueueFinanceLib.DepositInfo memory _depositInfo);

    // wallet -> poolId
    function getUserInfo(address _sender, uint256 _poolId)
        external
        view
        returns (QueueFinanceLib.UserInfo memory);


    function getRateInfoByPoolID(uint256 _poolId)
        external
        view
        returns (QueueFinanceLib.RateInfoStruct[][] memory _rateInfo)
    ;

    //Pool -> levels
    function levelsInfo(uint256 poolID, uint8 levelID)
        external
        view
        returns (QueueFinanceLib.LevelInfo memory);

    // Info of each pool.
    function getPoolInfo(uint256 _poolID)
        external
        view
        returns (QueueFinanceLib.PoolInfo memory);

    function currentSequenceIncrement(uint256 _poolID)
        external
        view
        returns (Counters.Counter memory);

    // Info of each pool.
    function treasury(uint256 _poolId) external view returns (address);

    // pool ->levels -> Threshold
    function currentThresholds(uint256 poolID, uint8 levelID)
        external
        view
        returns (QueueFinanceLib.Threshold memory);

    function requestedClaimInfo(address _sender, uint256 _poolId)
        external
        view
        returns (QueueFinanceLib.RequestedClaimInfo[] memory);

    function setOperator(address _operator, address _sender) external;

    function operator() external view returns (address);

    function setTransferOutOperator(address _operator, address _sender)
        external;

    function transferOutOperator() external view returns (address);

    function setLastUpdatedLevelForDeposits(
        uint256 _poolID,
        uint256 _seqID,
        uint8 _levelID,
        uint256 _amount
    ) external;

    function setDepositInfo(
        uint256 _poolID,
        uint256 _seqID,
        QueueFinanceLib.DepositInfo memory _depositInfo
    ) external;

    function setUserInfoForDeposit(
        address _sender,
        uint256 _poolID,
        uint256 _newSeqId,
        QueueFinanceLib.UserInfo memory _userInfo
    ) external;

    function setRateInfoStruct(
        uint256 _poolID,
        uint8 _levelID,
        QueueFinanceLib.RateInfoStruct memory _rateInfoStruct
    ) external;

    function setLevelsInfo(
        uint256 _poolID,
        uint8 _levelID,
        QueueFinanceLib.LevelInfo memory _levelsInfo
    ) external;

    function setPoolInfo(
        uint256 _poolID,
        QueueFinanceLib.PoolInfo memory _poolInfo
    ) external;

    // function s

    function setCurrentSequenceIncrement(
        uint256 _poolID,
        Counters.Counter memory _index
    ) external;

    function setTreasury(uint256 _poolID, address _treasury) external;

    function setCurrentThresholds(
        uint256 _poolID,
        uint256 _levelID,
        QueueFinanceLib.Threshold memory _threshold
    ) external;

    function setWithdrawTime(uint256 _withdrawTime) external;

    function setTaxAddress(uint256 _poolId, address _devTaxAddress, address _protocalTaxAddress, address _introducerAddress, address _networkAddress)
        external;

    function getTaxAddress(uint256 _poolId) external view returns (address[] memory);

    function getAllLevelInfo(uint256 _poolId)
        external
        view
        returns (QueueFinanceLib.LevelInfo[] memory);

    function getLastUpdatedLevelForEachDeposit(uint256 _poolId, uint256 _seqID)
        external
        view
        returns (uint256[] memory);

    function getAllThresholds(uint256 _poolId)
        external
        view
        returns (QueueFinanceLib.Threshold[] memory);

    function doCurrentSequenceIncrement(uint256 _poolID)
        external
        returns (uint256);

    function setLastUpdatedLevelsForDeposits(
        uint256 _poolID,
        uint256 _seqID,
        uint256[] memory _lastUpdatedLevelAmounts
    ) external;

    function setCurrentThresholdsForTxn(
        uint256 _poolId,
        QueueFinanceLib.Threshold[] memory _threshold
    ) external ;

    // @notice Sets the pool end time to extend the gen pools if required.
    function setPoolEndTime(uint256 _poolID, uint256 _pool_end_time) external;

    function setPoolStartTime(uint256 _poolID, uint256 _pool_start_time)
        external;

    function setEInvestValue(uint256 _poolID, uint256 _eInvestCoinValue)
        external;

    function checkRole(address account, bytes32 role) external view;

    function getPoolInfoLength() external view returns (uint256);

    function addPool(QueueFinanceLib.PoolInfo memory poolData) external;

    function setPoolIsPrivate(uint256 _poolID, bool _isPrivate) external;

    function getPoolIsPrivateForUser(uint256 _pid, address _user) external view returns (bool, bool);

    function setLevelInfo(
        uint256 _pid,
        uint8 _levelId,
        QueueFinanceLib.LevelInfo memory _levelInfo
    ) external;

    function pushRateInfoStruct(
        uint256 _poolID,
        QueueFinanceLib.RateInfoStruct memory _rateInfoStruct
    ) external;

    function incrementPoolInfoLevels(uint256 _poolId) external;

    function addLevelData(QueueFinanceLib.AddLevelData memory _addLevelData)
        external;

    // function fetchPoolTotalLevel(uint256 _poolId)
    //     external
    //     view
    //     returns (uint256);

    function fetchDepositsBasedonSequences(uint256 _poolId, uint256[] memory _sequenceIds)
        external
        view
        returns (QueueFinanceLib.DepositsBySequence[] memory)
    ;

    function getPoolStartTime(uint256 _poolId) external view returns (uint256);

    function getLatestRateInfoByPosition(
        uint256 _pid,
        uint256 _levelID,
        uint256 _position
    ) external view returns (QueueFinanceLib.RateInfoStruct memory);

    function getLatestRateInfo(uint256 _pid, uint256 _levelID)
        external
        view
        returns (QueueFinanceLib.RateInfoStruct memory);

    function pushRateInfo(
        uint256 _pid,
        uint256 _levelID,
        QueueFinanceLib.RateInfoStruct memory _rateInfo
    ) external;

    function setRateInfoByPosition(
        uint256 _pid,
        uint256 _levelID,
        uint256 _position,
        QueueFinanceLib.RateInfoStruct memory _rateInfo
    ) external;

    function setMaximumStakingAllowed(
        uint256 _pid,
        uint256 _maximumStakingAllowed
    ) external;

    function getRateInfoLength(uint256 _pid, uint256 _levelID)
        external
        view
        returns (uint256);

        function addReplenishReward(uint256 _poolID, uint256 _value) external ;

    function getRewardToken(uint256 _poolId) external view returns (IERC20);

       // @notice sets a pool's isStarted to true and increments total allocated points
    function startPool(uint256 _pid) external;

    function setTaxRates(
        uint256 _poolID,
        uint256[] memory _taxRates
    ) external ;

    function addPreApprovedUser(address[] memory userAddress) external ;

     function pushWholeRateInfoStruct(
        QueueFinanceLib.RateInfoStruct memory _rateInfoStruct
    ) external ;

    function returnDepositSeqList(uint256 _poodID, address _sender)
        external
        view
        returns (uint256[] memory)
    ;

     function getSequenceIdsFromCurrentThreshold(uint256 _poolId) external view returns (uint256[] memory);

      function fetchLastUpdatatedLevelsBySequenceIds(
        uint256 _poolID,
        uint256[] memory sequenceIds
    )
        external view 
        returns (QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[] memory)
    ;

    function pushRequestedClaimInfo(address _sender, uint256 _poolId, QueueFinanceLib.RequestedClaimInfo memory _requestedClaimInfo) external ;
    function getWithdrawTime() external view returns (uint256) ;

    function getRequestedClaimInfoIncrementer() external view returns (uint256);

    function getDepositBySequenceId(uint256 _poolId, uint256 _seqId) external view returns (QueueFinanceLib.DepositInfo memory);
       function setUserInfoForWithdraw(
        address _sender,
        uint256 _poolID,
        QueueFinanceLib.UserInfo memory _userInfo
    ) external ;

    function removeSeqAndUpdateUserInfo(uint256 _poolId, uint256 _seqId, address _sender,   uint256  _amount,
        uint256  _interest) external ;
    function updateAddressOnUserInfo(uint256 _pid,address _sender, address _referrel) external ;
    function getWithdrawRequestedClaimInfo(address _sender, uint256 _pid) external view returns (QueueFinanceLib.RequestedClaimInfo[] memory);
    function fetchWithdrawLength(uint256 _pid, address user)
        external
        view
        returns (uint256)
    ;
     function swapAndPopForWithdrawal(
        uint256 _pid,
        address user,
        uint256 clearIndex
    ) external ;

    function getTaxRates(uint256 _poolID)
        external
        view
        returns (uint256[] memory)
    ;

    function doTransfer(uint256 amount, address to, IERC20 depositToken) external ;

     function updatePoolBalance(uint256 _poolID, uint256 _amount, bool isIncrease)
        external
    ;

    function setDepositInfoForAddDeposit(
        uint256 _poolID,
        QueueFinanceLib.AddDepositInfo[] memory _addDepositInfo
    ) external ;

       function addDepositDetailsToDataContract(QueueFinanceLib.AddDepositModule memory _addDepositData)
        external ;

        function getDepositData(uint256 _poolId, address _sender)
        external
        view
        returns (QueueFinanceLib.AllDepositData memory)
    ;


    function setDepositsForDeposit(
        uint256 _pid,
        QueueFinanceLib.AddDepositInfo[] memory _deposits
    ) external ;
    function setLastUpdatedLevelsForSequences(uint256 _poolID, QueueFinanceLib.FetchLastUpdatedLevelsForDeposits[] memory _lastUpdatedLevels, 
        QueueFinanceLib.LastUpdatedLevelsPendings[] memory _lastUpdatedLevelsPendings) external ;
    function updateWithDrawDetails(QueueFinanceLib.UpdateWithdrawDataInALoop memory _withdrawData) external;
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;




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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// File: AdminContractQF.sol



pragma solidity ^0.8.4;






contract AdminContractQF {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IDataContractQF public iDataContractQF;

    constructor(address _accessContract) {
        iDataContractQF = IDataContractQF(_accessContract);
    }

    struct AdjustThresoldForLevelUpdateStruct{
        QueueFinanceLib.Threshold[] currentThresholds;
        uint256 level;
        uint256 iGap;
        bool isIncrease;
        QueueFinanceLib.DepositsBySequence[] depositInfo;
        QueueFinanceLib.LevelInfo[] levelsInfo;
        uint256 totalLevels;
        uint256 _pid;
    }

    function setDataContractAddress(address _dataContract) external {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF = IDataContractQF(_dataContract);
    }

    // Add a new farm to the pool. Can only be called by the owner.
    
    function add(
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
    ) public {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        require(iDataContractQF.getPoolInfoLength() == _pid, "PID wrong");

        uint256[] memory _taxRates = new uint256[](10);

        //push required
        QueueFinanceLib.PoolInfo memory poolInfo =  QueueFinanceLib.PoolInfo({
                totalStaked: 0,
                eInvestCoinValue: 1000000000000000000,
                depositToken: IERC20(_depositToken),
                rewardToken: IERC20(_rewardToken),
                isStarted: true,
                maximumStakingAllowed: _maximumStakingAllowed,
                currentSequence: 0,
                poolStartTime: _poolStartTime,
                poolEndTime: _poolEndTime,
                rewardsBalance: 0,
                levels: 1,
                lastActiveSequence: 0,
                taxRates: _taxRates
            });

        QueueFinanceLib.LevelInfo memory levelInfo = QueueFinanceLib.LevelInfo({
            levelStaked: 0,
            levelStakingLimit: _levelStakingLimit
        });

          QueueFinanceLib.RateInfoStruct memory rateInfo =  QueueFinanceLib.RateInfoStruct({rate: _rate, timestamp: _poolStartTime});

        QueueFinanceLib.DepositInfo memory depositInfo = QueueFinanceLib.DepositInfo({
            wallet: address(0),
            depositDateTime: _poolStartTime, // UTC
            initialStakedAmount: 0,
            iCoinValue: (1 * 10) ^ 18,
            stakedAmount: 0,
            accuredCoin: 0,
            claimedCoin: 0,
            lastUpdated: _poolStartTime,
            nextSequenceID: 0,
            previousSequenceID: 0,
            inactive: 0
        });
        QueueFinanceLib.Threshold memory threshold = QueueFinanceLib.Threshold({sequence: 0, amount: 0});
        iDataContractQF.addPool(poolInfo);
        iDataContractQF.setDepositInfo(_pid, 0, depositInfo);
        iDataContractQF.setLevelsInfo(_pid, 0, levelInfo);
        iDataContractQF.pushWholeRateInfoStruct(rateInfo);
        iDataContractQF.setCurrentThresholds(_pid, 0, threshold);
        iDataContractQF.setLastUpdatedLevelForDeposits(_pid, 0, 0, 0);
        iDataContractQF.setTreasury(_pid, _treasury);
        iDataContractQF.setPoolIsPrivate(_pid, _isPrivate);
    }


    function setCurrentThresholds(
        uint256 _pid,
        uint256 _level,
        uint256 _sequence,
        uint256 _amount
    ) public {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF.setCurrentThresholds(
            _pid,
            _level,
            QueueFinanceLib.Threshold({sequence: _sequence, amount: _amount})
        );
    }

    function addLevelsInfo(
        uint256 _poolID,
        uint256 _rate,
        uint256 _levelStakingLimit,
        uint8 _level
    ) public {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        QueueFinanceLib.PoolInfo memory poolInfo = iDataContractQF.getPoolInfo(_poolID);
        require(_level == poolInfo.levels, "Level mismatch");

        QueueFinanceLib.LevelInfo memory levelsInfo  = QueueFinanceLib.LevelInfo({
            levelStaked: 0,
            levelStakingLimit: _levelStakingLimit
        });

        QueueFinanceLib.RateInfoStruct memory rateInfo =  QueueFinanceLib.RateInfoStruct({rate: _rate, timestamp: poolInfo.poolStartTime});


        QueueFinanceLib.Threshold memory threholdInfo  = QueueFinanceLib.Threshold({
            sequence: 0,
            amount: 0
        });

        QueueFinanceLib.AddLevelData memory _addLevelData = QueueFinanceLib.AddLevelData({
              poolId: _poolID,
         levelId: _level,
         levelInfo: levelsInfo,
         rateInfo: rateInfo,
         threshold: threholdInfo
        });

        // iDataContractQF.addLevelData(_addLevelData);
        iDataContractQF.incrementPoolInfoLevels(_addLevelData.poolId);
        iDataContractQF.setLevelInfo(_addLevelData.poolId, _addLevelData.levelId, _addLevelData.levelInfo);
        iDataContractQF.pushRateInfoStruct(_addLevelData.poolId, _addLevelData.rateInfo);
        iDataContractQF.setCurrentThresholds(_addLevelData.poolId, _addLevelData.levelId, _addLevelData.threshold);

    }

    function getUpdateLevelRequiredData(uint256 _poolId) internal view returns (QueueFinanceLib.FetchUpdateLevelData memory) {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        return QueueFinanceLib.FetchUpdateLevelData({
             levelsInfo:iDataContractQF.getAllLevelInfo(_poolId),
             thresholds:iDataContractQF.getAllThresholds(_poolId),
             depositsInfo: iDataContractQF.fetchDepositsBasedonSequences(_poolId, iDataContractQF.getSequenceIdsFromCurrentThreshold(_poolId))
        });
    }


    function updateLevelInfoGlobal(
        uint256 _poolID,
        uint256 _levelID,
        // uint256 _levelStaked,
        uint256 _levelStakingLimit
    ) public view{
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        QueueFinanceLib.FetchUpdateLevelData memory fetchUpdateLevelData = getUpdateLevelRequiredData(_poolID);
        QueueFinanceLib.LevelInfo[] memory  levelsInfo  = fetchUpdateLevelData.levelsInfo;
        QueueFinanceLib.Threshold[] memory  currentThresholds  = fetchUpdateLevelData.thresholds;
        QueueFinanceLib.DepositsBySequence[] memory  depositsInfo  = fetchUpdateLevelData.depositsInfo;
        uint256 totalLevels = iDataContractQF.getPoolInfo(_poolID).levels;

        bool isIncrease = false;
        uint256 gap = 0;

        if (
            levelsInfo[_levelID].levelStakingLimit < _levelStakingLimit
        ) {
            isIncrease = true;
            gap = _levelStakingLimit.sub(
                levelsInfo[_levelID].levelStakingLimit
            );
        } else {
            gap = levelsInfo[_levelID].levelStakingLimit.sub(
                _levelStakingLimit
            );
        }

        levelsInfo[_levelID].levelStakingLimit = _levelStakingLimit;
        // create gap and progress.

        uint256[] memory levelUpdateAmounts = new uint256[](
            totalLevels
        );
        levelUpdateAmounts[_levelID] = gap;
        (levelsInfo) = updateLevelForBlockRemoval(levelsInfo, levelUpdateAmounts, true, totalLevels);
        //set 1 for global limit increase

        for (uint256 i = _levelID; i < totalLevels; i++) {
            //No blocks available for moving
            if (levelsInfo[i].levelStaked == 0) {
                currentThresholds[i].amount = 0;
                currentThresholds[i].sequence = 0;
                break;
            }


            adjustThresholdForLevelUpdate(AdjustThresoldForLevelUpdateStruct({
                  currentThresholds:currentThresholds,
         level:i,
         iGap:gap,
         isIncrease:isIncrease,
        depositInfo:depositsInfo,
     levelsInfo:levelsInfo,
         totalLevels:totalLevels,
         _pid:_poolID
            }));
        }
    }

    function adjustThresholdForLevelUpdate(
       AdjustThresoldForLevelUpdateStruct memory _adjustThresholdForLevelUpdateParams
    ) internal view {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        if (_adjustThresholdForLevelUpdateParams.isIncrease) {
            QueueFinanceLib.Threshold memory ths = _adjustThresholdForLevelUpdateParams.currentThresholds[_adjustThresholdForLevelUpdateParams.level];
            uint256 _thresholdConsumedTillLastLevel = thresholdConsumedTillLastLevel(
                 _adjustThresholdForLevelUpdateParams.currentThresholds,
                    ths.sequence,
                    _adjustThresholdForLevelUpdateParams.level
                );
            uint256 _total = QueueFinanceLib.pickDepositBySequenceId(_adjustThresholdForLevelUpdateParams.depositInfo, ths.sequence).initialStakedAmount;
            // calculate how much can be moved in the same block
          uint256 _levelStakingLimit =  _adjustThresholdForLevelUpdateParams.levelsInfo[_adjustThresholdForLevelUpdateParams.level].levelStakingLimit;

            uint256 _toAdjust = thresholdMoveInSameBlock(
                ths.amount,
                _thresholdConsumedTillLastLevel,
                _total,
                _adjustThresholdForLevelUpdateParams.iGap,
                _levelStakingLimit
            );
           _adjustThresholdForLevelUpdateParams.currentThresholds[_adjustThresholdForLevelUpdateParams.level].amount = _toAdjust;
            // calculate remaining gap
            _adjustThresholdForLevelUpdateParams.iGap = calculateRemainingGap(
                _thresholdConsumedTillLastLevel,
                ths.amount,
                _total,
                _levelStakingLimit,
                _adjustThresholdForLevelUpdateParams.iGap,
                _toAdjust
            );
            _adjustThresholdForLevelUpdateParams.currentThresholds = moveThresholdInALoop(_adjustThresholdForLevelUpdateParams.currentThresholds,_adjustThresholdForLevelUpdateParams.depositInfo, _adjustThresholdForLevelUpdateParams.level, _adjustThresholdForLevelUpdateParams.iGap,_adjustThresholdForLevelUpdateParams.totalLevels,_adjustThresholdForLevelUpdateParams._pid);
        }
        //isIncrease == NO
    }

    function moveThresholdInALoop(
        QueueFinanceLib.Threshold[] memory currentThresholds,
        QueueFinanceLib.DepositsBySequence[] memory depositInfo,
        uint256 level,
        uint256 iGap,
        uint256 totalLevels,
        uint256 _pid
    ) public view returns (QueueFinanceLib.Threshold[] memory) {
        QueueFinanceLib.DepositInfo memory currentSeqDeposit = QueueFinanceLib.pickDepositBySequenceId(
            depositInfo,
            currentThresholds[level].sequence
        );
        uint256 nextSeq = currentSeqDeposit.nextSequenceID;
        while ((iGap > 0) && (nextSeq > 0)) {
           QueueFinanceLib.DepositInfo memory nextSeqDeposit = iDataContractQF.getDepositBySequenceId(_pid, nextSeq);
            if (nextSeqDeposit.initialStakedAmount < iGap) {
                iGap -= nextSeqDeposit.initialStakedAmount;
                uint256 nextSeq1 = nextSeqDeposit.nextSequenceID;

                if (nextSeq1 == 0) {
                    currentThresholds[level].sequence = nextSeq;
                    currentThresholds[level].amount = getThresholdInfo(
                        currentThresholds,
                        nextSeqDeposit.initialStakedAmount,
                        totalLevels,
                        nextSeq
                    )[level];
                    break;
                }
                nextSeq = nextSeq1;
                continue;
            } else if (nextSeqDeposit.initialStakedAmount == iGap) {
                currentThresholds[level].sequence = nextSeq;
                currentThresholds[level].amount = currentSeqDeposit
                    .initialStakedAmount;
                iGap = 0;
                break;
            } else if (nextSeqDeposit.initialStakedAmount > iGap) {
                currentThresholds[level].sequence = nextSeq;
                currentThresholds[level].amount = iGap;
                iGap = 0;
                break;
            }
        }

        return currentThresholds;
    }




    function setInterestRate(
        uint256 _pid,
        uint256 _levelID,
        uint256 _date,
        uint256 _rate
    ) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));

        require(
            _date >= iDataContractQF.getPoolStartTime(_pid),
            "Interest date is earlier"
        );
        require(
            iDataContractQF.getLatestRateInfo(_pid, _levelID)
                .timestamp < _date,
            "Date should be greater than last "
        );

        iDataContractQF.pushRateInfo(_pid, _levelID, QueueFinanceLib.RateInfoStruct({rate: _rate, timestamp: _date}));

    }

    // Update maxStaking. Can only be called by the owner.
    function setMaximumStakingAllowed(
        uint256 _pid,
        uint256 _maximumStakingAllowed
    ) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF.setMaximumStakingAllowed(_pid, _maximumStakingAllowed);
    }

    //      Ensure to set the dates in ascending order
    function setInterestRatePosition(
        uint256 _pid,
        uint256 _levelID,
        uint256 _position,
        uint256 _date,
        uint256 _rate
    ) external {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        uint256 rateInfoLength = iDataContractQF.getRateInfoLength(_pid,_levelID);

            QueueFinanceLib.RateInfoStruct memory nextPositionRateInfo;
            QueueFinanceLib.RateInfoStruct memory previousPositionRateInfo;
        if(_position != 0){
            nextPositionRateInfo =  iDataContractQF.getLatestRateInfoByPosition(_pid, _levelID, _position + 1);
            previousPositionRateInfo =  iDataContractQF.getLatestRateInfoByPosition(_pid, _levelID, _position - 1);
        }

        //        assert if date is less than pool start time.
        require(
            _date >= iDataContractQF.getPoolStartTime(_pid),
            "Interest date is early"
        );
        // If position is zero just update
        // first record
        if ((rateInfoLength > 1) && (_position == 0)) {
            require(
                _date <= nextPositionRateInfo.timestamp,
                "The date not in asc order"
            );
        }
        // middle records
        if (
            (_position > 0) && (_position + 1 < rateInfoLength)
        ) {
            require(
                (_date >= previousPositionRateInfo.timestamp &&
                    _date <= nextPositionRateInfo.timestamp),
                "The date not in asc"
            );
        } else if (
            (_position + 1 == rateInfoLength) &&
            (_position > 0)
        ) {
            require(
                _date >= previousPositionRateInfo.timestamp,
                "The date should be in asc order"
            );
        }

        iDataContractQF.setRateInfoByPosition(_pid, _levelID, _position, QueueFinanceLib.RateInfoStruct({
            timestamp:_date,
            rate:_rate
        }));
    }

    // @notice Sets the pool end time to extend the gen pools if required.
    function setPoolEndTime(uint256 _poolID, uint256 _pool_end_time) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF.setPoolEndTime(_poolID, _pool_end_time);
    }

    function setPoolStartTime(uint256 _poolID, uint256 _pool_start_time)
        external
    {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF.setPoolStartTime(_poolID, _pool_start_time);

    }

    function setEInvestValue(uint256 _poolID, uint256 _eInvestCoinValue)
        external
    {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
            iDataContractQF.setEInvestValue(_poolID, _eInvestCoinValue);
    }

    // @notice imp. only use this function to replenish rewards
    function replenishReward(uint256 _poolID, uint256 _value) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF.addReplenishReward(_poolID,_value);
        IERC20(iDataContractQF.getRewardToken(_poolID)).safeTransferFrom(
            msg.sender,
            address(iDataContractQF),
            _value
        );
    }

    // @notice can only transfer out the rewards balance and not user fund.
    function transferOutECoin(
        uint256 _poolID,
        address _to,
        uint256 _value
    ) external {
        // onlyTransferOutOperator
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));


        IERC20(iDataContractQF.getRewardToken(_poolID)).safeTransfer(_to, _value);
    }

    //modify treasury address
    function setTreasury(uint256 _pId, address _treasury) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));

        iDataContractQF.setTreasury(_pId, _treasury);
    }

    function setWithdrawTime(uint256 _timeSpan) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
    iDataContractQF.setWithdrawTime(_timeSpan);
    }

    function updateTaxRates(
        uint256 _poolID,
        uint256 _depositDev,
        uint256 _depositProtocal,
        uint256 _depositIntroducer,
        uint256 _depositNetwork,
        uint256 _depositRefferel,
        uint256 _withdrawDev,
        uint256 _withdrawProtocal,
        uint256 _withdrawIntroducer,
        uint256 _withdrawNetwork,
        uint256 _withdrawRefferel
    ) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));

        uint256[] memory _taxRates = new uint256[](10);
        _taxRates[0] = _depositDev;
        _taxRates[1] = _depositProtocal;
        _taxRates[2] = _depositIntroducer;
        _taxRates[3] = _depositNetwork;
        _taxRates[4] = _depositRefferel;
        _taxRates[5] = _withdrawDev;
        _taxRates[6] = _withdrawProtocal;
        _taxRates[7] = _withdrawIntroducer;
        _taxRates[8] = _withdrawNetwork;
        _taxRates[9] = _withdrawRefferel;
        iDataContractQF.setTaxRates(_poolID, _taxRates);
    }

    function updateTaxAddress(
        uint256 _poolId,
        address _devTaxAddress,
        address _protocalTaxAddress,
        address _introducerTaxAddress,
        address _networkTaxAddress
    ) external {
        iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));
        iDataContractQF.setTaxAddress(_poolId, _devTaxAddress, _protocalTaxAddress, _introducerTaxAddress, _networkTaxAddress);
    }

    function addPreApprovedUser(address[] memory userAddress) external {
                iDataContractQF.checkRole(msg.sender, keccak256("ADMIN_ROLE"));

       iDataContractQF.addPreApprovedUser(userAddress);
    }



    function calculateRemainingGap(
        uint256 _thresholdConsumedTillLastLevel,
        uint256 _currentThreshold,
        uint256 _total,
        uint256 _levelStakingLimit,
        uint256 iGap,
        uint256 _toAdjust
    ) public pure returns (uint256) {
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

      function updateLevelForBlockRemoval(
        QueueFinanceLib.LevelInfo[] memory levelsInfo,
        uint256[] memory _ths,
        bool addFlag,
        uint256 _totalLevels
    ) public pure returns (QueueFinanceLib.LevelInfo[] memory) {
        // uint256 amountToMove;
        bool iStarted = false;
        uint256 iStart = 0;
        uint256 iSum = 0;

        for (uint256 i = 0; i < _ths.length; i++) {
            // exclude this condition if addFlag is 1
            if (
                _ths[i] > 0 &&
                iStarted == false &&
                ((levelsInfo[i].levelStaked >= _ths[i]) || addFlag)
            ) {
                iStarted = true;
                iStart = i;
                iSum = levelsInfo[i].levelStaked;
                if (!addFlag) {
                    iSum = iSum.sub(_ths[i]);
                }
            } else if (levelsInfo[i].levelStaked >= _ths[i]) {
                iSum += levelsInfo[i].levelStaked;
                if (!addFlag) {
                    iSum = iSum.sub(_ths[i]);
                }
            }
        }
        for (
            uint256 i = iStart;
            i < _totalLevels;
            i++ // iEnd  upto all levels
        ) {
            levelsInfo[i].levelStaked = QueueFinanceLib.min(
                iSum,
                levelsInfo[i].levelStakingLimit
            );
            iSum = iSum.sub(levelsInfo[i].levelStaked);
        }

        return levelsInfo;
    }


    function thresholdConsumedTillLastLevel(
        QueueFinanceLib.Threshold[] memory currentThresholds,
        uint256 _sequence,
        uint256 _level
    ) public pure returns (uint256) {
        uint256 thresholdConsumedValue = 0;

        for (uint256 level = _level; level >= 0; level--) {
            if (_sequence == currentThresholds[level].sequence) {
                thresholdConsumedValue += currentThresholds[level].amount;
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
            _toAdjust = QueueFinanceLib.min(_toAdjust, _levelStakingLimit);
        }
        return _toAdjust;
    }


    function getThresholdInfo(
        QueueFinanceLib.Threshold[] memory currentThresholds,
        uint256 depositStakeAmount,
        uint256 totalLevels,
        uint256 _sequenceID
    ) public pure returns (uint256[] memory) {
        uint256 iStakedAmount = depositStakeAmount;
        uint256[] memory ths = new uint256[](totalLevels);
        QueueFinanceLib.Threshold memory th;
        uint256 pos = 0;

        for (uint256 i = 0; i < totalLevels; i++) {
            if (iStakedAmount <= 0) break;

            th = currentThresholds[i];
            if (th.sequence < _sequenceID) {
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
}


pragma solidity ^0.8.0;

interface IDepositContractQF {
    function deposit(uint256 _pid, uint256 _amount) external ;
    function depositFromWithdraw(uint256 _pid, uint256 _amount,bool isInternal, address  _sender) external ;
    function updateAddressOnUserInfo(uint256 _pid,address _sender, address _referrel) external ;
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