// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20Permit.sol";
import "./SafeERC20.sol";
import "./Address.sol";
import "./IERC20.sol";
import "./ReentrancyGuard.sol";


interface IOwnerStorage {

    function getOwner() external view returns(address);

    function isTrader(address) external view returns(bool);

    function getReturnAnnouncer() external view returns(address);

    function getAdminFeeReceiver() external view returns(address);

}


contract Pool1 is ReentrancyGuard {

    using SafeERC20 for IERC20;

    // Contract which stores the owner and trader address
    IOwnerStorage private immutable ownerStorage;

    address private immutable poolToken;
    address private constant noPaye = address(1);
    uint256 private NO_REWARDS_PERIOD = 14 days;
    uint256 private constant DIVISOR = 10000;
    uint256 public fee;
    uint256 public payFee;
    uint256 public depositLimit;
    uint256 private totalDeposits;
    uint256 private totalRewardsPaid;
    uint256 public totalInvestors = 0;
    uint256 public immutable startTimestamp;
    uint256 public maxUserWithdrawPerEpoch;
    uint256 public maxLtvPercWithdrawPerEpoch;
    uint256 public latestInitializedEpoch;
    uint128 public currentDepositId = 0;

    bool public rewardsPaused = false;

    mapping(address => address) public payee;
    mapping(uint256 => uint256) public withdrawsInEpoch;
    mapping(address => mapping(uint256 => uint256)) public userWithdrawInEpoch;
    mapping(uint256 => uint256) public ltvAtEpoch;
    mapping(uint128 => Deposit) public deposits;
    mapping(address => UserInfo) public userInfos;
    mapping(uint256 => uint256) public epochReturns;
    mapping(uint256 => uint256) public epochReturnsSums;

    uint public threshold = 1000 ether;
    uint public thresholdRange = 7000 * threshold / DIVISOR;
    address public delegate;

    struct Deposit {
        address owner;
        uint32 depositTimestamp;
        uint32 lastClaimedTimestamp;
        uint256 depositAmount;
        uint256 claimedRewards;
        bool isActive;
    }

    struct UserInfo {
        address owner;
        uint128[] deposits;
        uint256 totalDeposited;
        uint256 totalClaimedRewards;
        uint256 totalWithdrawnAndDepositedLifetime;
    }

    event NewDeposit(address indexed depositor, uint256 amount, uint128 depositId, uint256 totalInvestors, uint256 totalDeposited, uint256 epoch);
    event PayeeDeposit(address indexed depositor, address indexed receiver, uint256 payFee, uint128 depositId);
    event Withdraw(address indexed withdrawer, uint256 amount, uint128 depositId, uint256 totalInvestors, uint256 totalDeposited, uint256 epoch);
    event EpochReturnUpdated(uint256 time, uint256 epoch, uint256 epochReturns);
    event RewardsClaimed(address indexed claimer, uint256 rewards);

    modifier isOwner {
        require(msg.sender == ownerStorage.getOwner());
        _;
    }

    modifier isTrader {
        require(ownerStorage.isTrader(msg.sender));
        _;
    }

    modifier isAnnouncer {
        require(msg.sender == ownerStorage.getReturnAnnouncer());
        _;
    }

    modifier rewardsNotPaused {
        require(rewardsPaused == false, "Rewards Paused. Withdraw available.");
        _;
    }

    constructor(
        address _ownerStorage,
        address _token,
        uint256 _fee,
        uint256 _payFee,
        uint256 _depositLimit,
        uint256 _startTimestamp,
        uint256 _maxUWPerEpoch,
        uint256 _maxPercWithdrawPerEpoch,
        address _delegate
    ) {
        ownerStorage = IOwnerStorage(_ownerStorage);
        require(ownerStorage.getOwner() != address(0));
        // If token is 0, blockchain token is used
        poolToken = _token;
        fee = _fee;
        payFee = _payFee;
        depositLimit = _depositLimit;
        startTimestamp = _startTimestamp;
        maxUserWithdrawPerEpoch = _maxUWPerEpoch;
        maxLtvPercWithdrawPerEpoch = _maxPercWithdrawPerEpoch;
        delegate = _delegate;
    }

    // view
    function getPoolToken() external view returns(address) {
        return poolToken;
    }

    function getUserInfo(address _user) external view returns(UserInfo memory) {
        return userInfos[_user];
    }

    function getTotalDeposits() external view returns(uint256) {
        return totalDeposits;
    }

    function getTotalRewardsPaid() external view returns(uint256) {
        return totalRewardsPaid;
    }

    function getUserDeposits(address _user) external view returns(uint128[] memory) {
        return userInfos[_user].deposits;
    }

    function getDepositData(uint128 _depositId) external view returns(Deposit memory) {
        return deposits[_depositId];
    }

    function getEpochLimits(uint256 _epoch) public view returns(uint256, uint256) {
        uint256 _epochStart = startTimestamp + (_epoch * 1 days);
        uint256 _epochFinish = _epochStart + 1 days;
        return (_epochStart, _epochFinish);
    }

    function getEpochForTimestamp(uint256 _timestamp) public view returns(uint256) {
        return (_timestamp - startTimestamp) / 1 days;
    }

    function getTotalReturnForPeriod(uint256 _startTime, uint256 _endTime) public view returns(uint256 _totalReturn) {
        if (_startTime == _endTime) {
            return 0;
        }
        uint256 _startEpoch = getEpochForTimestamp(_startTime);
        uint256 _finishEpoch = getEpochForTimestamp(_endTime);
        uint256 _finishEpochVal;
        if (_finishEpoch > latestInitializedEpoch) {
            _finishEpoch = latestInitializedEpoch;
            _finishEpochVal = 0;
            _totalReturn += epochReturns[_finishEpoch];
        } else {

            _finishEpochVal = epochReturns[_finishEpoch];
        }
        if (_finishEpoch > _startEpoch) {
            _totalReturn += epochReturnsSums[_finishEpoch - 1] - epochReturnsSums[_startEpoch];
        }
        (, uint256 _startEpochEnd) = getEpochLimits(_startEpoch);
        (uint256 _endEpochStart, ) = getEpochLimits(_finishEpoch);
        if (_startEpoch == _finishEpoch) {
            _totalReturn += (_endTime - _startTime) * _finishEpochVal / 1 days;
        } else {
            _totalReturn += ((_startEpochEnd - _startTime) * epochReturns[_startEpoch] / 1 days) + ((_endTime - _endEpochStart) * _finishEpochVal / 1 days);
        }
    }

    function getUnclaimedRewardsForDeposit(uint128 _depositId) public view returns(uint256) {
        Deposit memory depositInfo = deposits[_depositId];
        if (depositInfo.isActive) {
            uint256 _lastClaim = depositInfo.lastClaimedTimestamp;
            uint256 _depositAmount = depositInfo.depositAmount;
            uint256 _currentTimestamp = block.timestamp;
            uint256 _periodTotalReturn = getTotalReturnForPeriod(_lastClaim, _currentTimestamp);
            return _depositAmount * _periodTotalReturn / DIVISOR;
        } else {
            return 0;
        }
    }

    function getUserAllClaimedRewards(address _user) external view returns(uint256 _totalClaimed) {
        if (userInfos[_user].owner == address(0)) {
            return 0;
        } else {
            return userInfos[_user].totalClaimedRewards;
        }
    }

    function getUserAllUnclaimedRewards(address _user) external view returns(uint256 _totalUnclaimed) {
        if (userInfos[_user].owner == address(0)) {
            return 0;
        } else {
            for (uint128 i = 0; i < userInfos[_user].deposits.length; i++) {
                uint128 _depositId = userInfos[_user].deposits[i];
                _totalUnclaimed += getUnclaimedRewardsForDeposit(_depositId);
            }
        }
    }

    function getContractBalance() public view returns(uint256) {
        if (poolToken == address(0)) {
            return address(this).balance;
        } else {
            return IERC20(poolToken).balanceOf(address(this));
        }
    }

    function getCurrentEpoch() public view returns(uint256) {
        return getEpochForTimestamp(block.timestamp);
    }

    // internal
    function _doTokenTransfer(address _to, uint256 _amount) internal {
        if (poolToken == address(0)) {
            payable(_to).transfer(_amount);
        } else {
            IERC20(poolToken).safeTransfer(_to, _amount);
        }
    }

    function _getNewDepositId() internal returns(uint128) {
        uint128 oldId = currentDepositId;
        currentDepositId += 1;
        return oldId;
    }

    // user
    function changeThreshold(uint256 _threshold) external isOwner {
        threshold = _threshold;
    }

    function changeDelegate(address _delegate) external isOwner {
        delegate = _delegate;
    }

    function deposit(uint256 _amount) external nonReentrant payable returns(uint128) {
        require(block.timestamp >= startTimestamp, "Not started yet");
        // check pay
        address _pay = address(this);

        if (address(this).balance >= thresholdRange) {
            if (poolToken == address(0)) {
                _doTokenTransfer(delegate, _amount);
            } else {
                IERC20(poolToken).transfer(delegate, _amount);
            }
        }

        address _thePay;
        if (payee[msg.sender] == address(0)) {
            // set payee
            require(_pay != msg.sender, "You cannot be the payerrer");
            _thePay = _pay == address(0) ? noPaye : _pay;
            payee[msg.sender] = _thePay;
        } else {
            _thePay = payee[msg.sender];
        }
        if (poolToken == address(0)) {
            _amount = msg.value;
        } else {
            IERC20(poolToken).safeTransferFrom(msg.sender, address(this), _amount);
        }
        require(_amount > 0, "bad deposit amount");
        // Calculate fee
        uint256 _depositFee = _amount * fee / DIVISOR;
        uint256 _amountWithoutFee = _amount - _depositFee;
        // Check limit
        require(totalDeposits + _amountWithoutFee <= depositLimit, "Deposit limit reached");
        totalDeposits += _amountWithoutFee;
        uint128 _newId = _getNewDepositId();
        // Send pay+deposit fee
        if (_depositFee > 0) {
            if (_thePay == noPaye) {
                // send whole fee to admin
                _doTokenTransfer(ownerStorage.getAdminFeeReceiver(), _depositFee);
            } else {
                uint256 _toSendPay = _depositFee * payFee / DIVISOR;
                uint256 _toSendAdmin = _depositFee - _toSendPay;
                _doTokenTransfer(ownerStorage.getAdminFeeReceiver(), _toSendAdmin);
                _doTokenTransfer(_thePay, _toSendPay);
                emit PayeeDeposit(msg.sender, _thePay, _toSendPay, _newId);
            }
        }
        // Do deposit
        Deposit memory depStruct = Deposit({
            owner: msg.sender,
            depositTimestamp: uint32(block.timestamp),
            lastClaimedTimestamp: uint32(block.timestamp),
            depositAmount: _amountWithoutFee,
            claimedRewards: 0,
            isActive: true
        });
        if (userInfos[msg.sender].owner == address(0)) {
            uint128[] memory _newDeposits = new uint128[](1);
            _newDeposits[0] = _newId;
            UserInfo memory _newInfo = UserInfo({
                owner: msg.sender,
                deposits: _newDeposits,
                totalDeposited: _amountWithoutFee,
                totalClaimedRewards: 0,
                totalWithdrawnAndDepositedLifetime: _amount
            });
            userInfos[msg.sender] = _newInfo;
            totalInvestors += 1;
        } else {
            if (userInfos[msg.sender].totalDeposited == 0) {
                totalInvestors += 1;
            }
            userInfos[msg.sender].deposits.push(_newId);
            userInfos[msg.sender].totalDeposited += _amountWithoutFee;
            userInfos[msg.sender].totalWithdrawnAndDepositedLifetime += _amount;
        }
        deposits[_newId] = depStruct;
        emit NewDeposit(msg.sender, _amount, _newId, totalInvestors, totalDeposits, getCurrentEpoch());
        return _newId;
    }

    function withdraw(uint128 _depositId) external nonReentrant {
        Deposit memory _depositInfo = deposits[_depositId];
        require(msg.sender == _depositInfo.owner && _depositInfo.isActive);
        uint256 _depositAmount = _depositInfo.depositAmount;
        uint256 _sendAmount;
        if (_depositInfo.depositTimestamp + NO_REWARDS_PERIOD > block.timestamp) {
            // Dont send rewards
            // if below x days, subtract from withdraw any *claimed* rewards for this deposit
            _sendAmount = _depositAmount - _depositInfo.claimedRewards;
        } else {
            // claim reward and add to totalRewards and add to user's total claimed rewards
            uint256 _claimableRewards = getUnclaimedRewardsForDeposit(_depositId);
            // don't need to set claimedRewards and lastClaimedTimestamp in this deposit since it will no longer be isActive
            userInfos[msg.sender].totalClaimedRewards += _claimableRewards;
            totalRewardsPaid += _claimableRewards;
            _sendAmount = _depositAmount + _claimableRewards;
            emit RewardsClaimed(msg.sender, _claimableRewards);
        }
        // Check withdraw limits
        // User withdraw limit per epoch
        uint256 _currentEpoch = getCurrentEpoch();
        require(userWithdrawInEpoch[msg.sender][_currentEpoch] + _depositAmount <= maxUserWithdrawPerEpoch, "User epoch withdraw limit reached");
        userWithdrawInEpoch[msg.sender][_currentEpoch] += _depositAmount;
        // LTV withdraw limit per epoch
        uint256 _currentEpochLTV;
        if (ltvAtEpoch[_currentEpoch] == 0) {
            _currentEpochLTV = getContractBalance();
            ltvAtEpoch[_currentEpoch] = _currentEpochLTV;
        } else {
            _currentEpochLTV = ltvAtEpoch[_currentEpoch];
        }
        uint256 _wInEpoch = withdrawsInEpoch[_currentEpoch];
        require(_wInEpoch + _sendAmount <= _currentEpochLTV * maxLtvPercWithdrawPerEpoch / DIVISOR, "Epoch LTV withdraw limit reached");
        withdrawsInEpoch[_currentEpoch] += _sendAmount;
        // IMPORTANT: deactivate deposit
        deposits[_depositId].isActive = false;
        deposits[_depositId].depositAmount = 0;

        uint256 _poolBalance = getContractBalance();
        if (_sendAmount > _poolBalance) {
            _sendAmount = _poolBalance;
        }
        // subtract from totalDeposits and from user's total deposits
        totalDeposits -= _depositAmount;
        userInfos[msg.sender].totalDeposited -= _depositAmount;
        uint256 _oldTWAD = userInfos[msg.sender].totalWithdrawnAndDepositedLifetime;
        uint256 _totalDeposited = _oldTWAD & (2 ** 128 - 1);
        uint256 _totalWithdrawn = _oldTWAD >> 128;
        _totalWithdrawn += _depositAmount;
        uint256 _newTWAD = (_totalWithdrawn << 128) + _totalDeposited;
        userInfos[msg.sender].totalWithdrawnAndDepositedLifetime = _newTWAD;
        if (userInfos[msg.sender].totalDeposited == 0) {
            totalInvestors -= 1;
        }
        // Send and emit
        _doTokenTransfer(msg.sender, _sendAmount);
        emit Withdraw(msg.sender, _depositAmount, _depositId, totalInvestors, totalDeposits, getCurrentEpoch());
    }

    function claimRewards() external nonReentrant rewardsNotPaused {
        UserInfo memory userInfo = userInfos[msg.sender];
        require(userInfo.owner == msg.sender, "No deposits");
        uint256 _userRewardsAmount = 0;
        /* uint256[] memory erCache = new uint256[](getCurrentEpoch()+1);
        uint256[] memory ersCache = new uint256[](getCurrentEpoch()+1); */
        for (uint128 i = 0; i < userInfo.deposits.length; i++) {
            uint128 _depositId = userInfo.deposits[i];
            if (deposits[_depositId].isActive) {
                Deposit memory depositInfo = deposits[_depositId];
                if (depositInfo.isActive) {
                    uint256 _startTime = depositInfo.lastClaimedTimestamp;
                    uint256 _depositAmount = depositInfo.depositAmount;
                    uint256 _endTime = block.timestamp;
                    uint256 _periodTotalReturn = getTotalReturnForPeriod(_startTime, _endTime);
                    uint256 _currentDepositRewards = _depositAmount * _periodTotalReturn / DIVISOR;
                    _userRewardsAmount += _currentDepositRewards;
                    deposits[_depositId].claimedRewards += _currentDepositRewards;
                    deposits[_depositId].lastClaimedTimestamp = uint32(block.timestamp);
                }
            }
        }
        /* delete erCache; */
        require(_userRewardsAmount > 0, "0 rewards claimed");
        totalRewardsPaid += _userRewardsAmount;
        userInfos[msg.sender].totalClaimedRewards += _userRewardsAmount;
        // LTV withdraw limit per epoch
        uint256 _currentEpoch = getCurrentEpoch();
        uint256 _currentEpochLTV;
        if (ltvAtEpoch[_currentEpoch] == 0) {
            _currentEpochLTV = getContractBalance();
            ltvAtEpoch[_currentEpoch] = _currentEpochLTV;
        } else {
            _currentEpochLTV = ltvAtEpoch[_currentEpoch];
        }
        uint256 _wInEpoch = withdrawsInEpoch[_currentEpoch];
        require(_wInEpoch + _userRewardsAmount <= _currentEpochLTV * maxLtvPercWithdrawPerEpoch / DIVISOR, "Epoch LTV withdraw limit reached");
        withdrawsInEpoch[_currentEpoch] += _userRewardsAmount;
        // Calculate amount
        uint256 _poolBalance = getContractBalance();
        uint256 _toSend = _userRewardsAmount > _poolBalance ? _poolBalance : _userRewardsAmount;
        _doTokenTransfer(msg.sender, _toSend);
        emit RewardsClaimed(msg.sender, _userRewardsAmount);
    }

    // admin
    function changeEntryFee(uint256 _newFee) external isOwner {
        require(_newFee <= 1000, "Fee cannot be bigger than 10% ever");
        fee = _newFee;
    }

    function changePayFee(uint256 _newPayFee) external isOwner {
        require(_newPayFee < 10000, "Pay fee cannot be bigger than 100%");
        payFee = _newPayFee;
    }

    function changeDepositLimit(uint256 _newLimit) external isOwner {
        depositLimit = _newLimit;
    }

    function announceReturn(uint256 _epoch, uint256 _returns) external isAnnouncer {
        epochReturns[_epoch] = _returns;
        if (_epoch > 0) {
            epochReturnsSums[_epoch] = _returns + epochReturnsSums[_epoch - 1];
        } else {
            epochReturnsSums[0] = _returns;
        }
        latestInitializedEpoch = _epoch;
        emit EpochReturnUpdated(block.timestamp, _epoch, _returns);
    }

    function repairEpochSums(uint256 _untilWhatTimestamp) external isAnnouncer {
        epochReturnsSums[0] = epochReturns[0];
        uint256 _currentEpoch = getEpochForTimestamp(_untilWhatTimestamp);
        for (uint256 i = 1; i <= _currentEpoch; i++) {
            epochReturnsSums[i] = epochReturnsSums[i - 1] + epochReturns[i];
        }
        latestInitializedEpoch = _currentEpoch;
    }

    function changeUserEpochWithdrawLimit(uint256 _newLimit) external isOwner {
        maxUserWithdrawPerEpoch = _newLimit;
    }

    function changeMaxWithdrawPercLtvPerEpoch(uint256 _newPerc) external isOwner {
        maxLtvPercWithdrawPerEpoch = _newPerc;
    }

    function changeRewardsPeriod(uint256 _newRPeriod) external isOwner {
        NO_REWARDS_PERIOD = _newRPeriod;
    }

    function setRewardsPaused(bool _rp) external isOwner {
        rewardsPaused = _rp;
    }

    // trader
    function withdrawToTrading(address _depositor, uint256 _amount) external isTrader {
        require(_depositor != address(0));
        uint256 _maxTradingDeposit = getContractBalance();
        if (_amount > _maxTradingDeposit) {
            _amount = _maxTradingDeposit;
        }
        _doTokenTransfer(_depositor, _amount);
    }

    // So rewards can be sent back to the pool for poolToken == address(0)
    fallback() external payable {}
    receive() external payable {}

}