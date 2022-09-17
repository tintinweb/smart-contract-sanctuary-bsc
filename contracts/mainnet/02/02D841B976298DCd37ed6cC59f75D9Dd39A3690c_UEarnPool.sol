/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsPool is Ownable {
    struct Pool {
        uint256 duration;
        uint256 rewardRate;
        uint256 totalAmount;
    }

    struct UserInfo {
        uint256 amount;
        bool active;
        uint256 inviteReward;
        uint256 teamAccount;
        uint256 teamAmount;
        mapping(uint256 => uint256) levelClaimed;
    }

    struct Record {
        uint256 pid;
        uint256 amount;
        uint256 feeAmount;
        uint256 reward;
        uint256 start;
        uint256 end;
        uint256 status;
    }

    struct LevelConfig {
        uint256 rewardRate;
        uint256 teamAmount;
        uint256 amount;
    }

    address private _tokenAddress;
    Pool[] private _pools;
    mapping(address => Record[]) private _userRecords;
    mapping(address => UserInfo) private _userInfos;
    mapping(uint256 => LevelConfig) private _levelConfigs;
    bool private _pause;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;

    uint256 private _minAmount;
    mapping(uint256 => uint256) public _inviteFee;
    uint256 public _amountUnit;
    uint256 public _teamLength = 20;
    uint256 public _inviteLength = 5;
    uint256 public _levelLength = 4;
    uint256 public constant _feeDivFactor = 10000;

    uint256 public _feeRate = 300;

    uint256 public constant MAX = ~uint256(0);

    constructor(address TokenAddress){
        _tokenAddress = TokenAddress;

        _pools.push(Pool(7 days, 400, 0));
        _pools.push(Pool(30 days, 1800, 0));
        _pools.push(Pool(60 days, 4000, 0));
        _pools.push(Pool(90 days, 6600, 0));
        _pools.push(Pool(180 days, 14000, 0));

        uint256 amountUnit = 10 ** IERC20(TokenAddress).decimals();
        _amountUnit = amountUnit;
        _minAmount = 100 * amountUnit;
        _inviteFee[0] = 300;
        _inviteFee[1] = 200;
        _inviteFee[2] = 100;
        _inviteFee[3] = 100;
        _inviteFee[4] = 50;
        _levelConfigs[0] = LevelConfig(100, 300000 * amountUnit, 3000 * amountUnit);
        _levelConfigs[1] = LevelConfig(300, 600000 * amountUnit, 7000 * amountUnit);
        _levelConfigs[2] = LevelConfig(500, 1200000 * amountUnit, 10000 * amountUnit);
        _levelConfigs[3] = LevelConfig(1000, 2400000 * amountUnit, 20000 * amountUnit);
        _levelLength = 4;
    }

    function bindInvitor(address invitor) external {
        address account = msg.sender;
        require(invitor != account, "self");
        require(address(0) != invitor, "invitor 0");
        require(address(0) == _invitor[account], "Bind");
        require(!_userInfos[account].active, "active");
        require(_binder[account].length == 0, "had binders");
        _invitor[account] = invitor;
        _binder[invitor].push(account);
        uint256 len = _inviteLength;
        for (uint256 i; i < len;) {
            if (address(0) == invitor) {
                break;
            }
            _userInfos[invitor].teamAccount += 1;
            invitor = _invitor[invitor];
        unchecked{
            ++i;
        }
        }
    }

    function stake(uint256 pid, uint256 amount) external {
        require(!_pause, "Pause");
        uint256 unit = _amountUnit;
        amount = amount / unit;
        amount = amount * unit;
        require(amount >= _minAmount, "<min");
        address account = msg.sender;

        Pool storage pool = _pools[pid];
        pool.totalAmount += amount;

        uint256 reward = amount * pool.rewardRate / _feeDivFactor;
        uint256 feeAmount = amount * _feeRate / _feeDivFactor;
        _userRecords[account].push(
            Record(pid, amount, feeAmount, reward, block.timestamp, block.timestamp + pool.duration, 0)
        );
        UserInfo storage userInfo = _userInfos[account];
        userInfo.amount += amount;
        if (!userInfo.active) {
            userInfo.active = true;
        }

        IERC20 token = IERC20(_tokenAddress);
        token.transferFrom(account, address(this), amount);

        _addInviteReward(account, amount);
        _addTeamAmount(account, amount);
    }

    function _addInviteReward(address account, uint256 amount) private {
        uint256 inviteLength = _inviteLength;
        UserInfo storage invitorInfo;
        address invitor;
        IERC20 token = IERC20(_tokenAddress);
        for (uint256 i; i < inviteLength;) {
            invitor = _invitor[account];
            if (address(0) == invitor) {
                break;
            }
            account = invitor;
            invitorInfo = _userInfos[invitor];
        unchecked{
            uint256 inviteReward = amount * _inviteFee[i] / _feeDivFactor;
            if (inviteReward > 0) {
                invitorInfo.inviteReward += inviteReward;
                token.transfer(invitor, inviteReward);
            }
            ++i;
        }
        }
    }

    function _addTeamAmount(address account, uint256 amount) private {
        uint256 teamLength = _teamLength;
        UserInfo storage invitorInfo;
        address invitor;
        for (uint256 i; i < teamLength;) {
            invitor = _invitor[account];
            if (address(0) == invitor) {
                break;
            }
            account = invitor;
            invitorInfo = _userInfos[invitor];
        unchecked{
            invitorInfo.teamAmount += amount;
            ++i;
        }
        }
    }

    function unStake(uint256 index) external {
        address account = msg.sender;
        Record storage record = _userRecords[account][index];
        require(0 == record.status, "unlock");
        require(block.timestamp >= record.end, "no end");
        record.status = 1;

        uint256 amount = record.amount;
        IERC20(_tokenAddress).transfer(account, amount + record.reward - record.feeAmount);
        _userInfos[account].amount -= amount;
        _pools[record.pid].totalAmount -= amount;

        _minusTeamAmount(account, amount);
    }

    function _minusTeamAmount(address account, uint256 amount) private {
        uint256 teamLength = _teamLength;
        UserInfo storage invitorInfo;
        address invitor;
        for (uint256 i; i < teamLength;) {
            invitor = _invitor[account];
            if (address(0) == invitor) {
                break;
            }
            account = invitor;
            invitorInfo = _userInfos[invitor];
        unchecked{
            invitorInfo.teamAmount -= amount;
            ++i;
        }
        }
    }

    function poolInfo(uint256 pid) public view returns (uint256 duration, uint256 rewardRate, uint256 totalAmount){
        Pool storage pool = _pools[pid];
        duration = pool.duration;
        rewardRate = pool.rewardRate;
        totalAmount = pool.totalAmount;
    }

    function pools() external view returns (
        uint256[] memory duration, uint256[] memory rewardRate, uint256[] memory totalAmount
    ){
        uint256 len = _pools.length;
        duration = new uint256[](len);
        rewardRate = new uint256[](len);
        totalAmount = new uint256[](len);
        for (uint256 i; i < len; ++i) {
            (duration[i], rewardRate[i], totalAmount[i]) = poolInfo(i);
        }
    }

    function getRecords(
        address account,
        uint256 start,
        uint256 length
    ) external view returns (
        uint256 returnCount,
        uint256[] memory pid,
        uint256[] memory amount,
        uint256[] memory reward,
        uint256[] memory endTime,
        uint256[] memory status
    ){
        uint256 recordLen = _userRecords[account].length;
        if (0 == length) {
            length = recordLen;
        }
        returnCount = length;
        pid = new uint256[](length);
        amount = new uint256[](length);
        reward = new uint256[](length);
        endTime = new uint256[](length);
        status = new uint256[](length);
        uint256 index = 0;
        for (uint256 i = start; i < start + length; i++) {
            if (i >= recordLen) {
                return (index, pid, amount, reward, endTime, status);
            }
            Record storage record = _userRecords[account][i];
            pid[index] = record.pid;
            amount[index] = record.amount;
            reward[index] = record.reward;
            endTime[index] = record.end;
            status[index] = record.status;
            index++;
        }
    }

    function getRecordsExt(
        address account,
        uint256 start,
        uint256 length
    ) external view returns (
        uint256 returnCount,
        uint256[] memory feeAmount,
        uint256[] memory startTime
    ){
        uint256 recordLen = _userRecords[account].length;
        if (0 == length) {
            length = recordLen;
        }
        returnCount = length;
        feeAmount = new uint256[](length);
        startTime = new uint256[](length);
        uint256 index = 0;
        for (uint256 i = start; i < start + length; i++) {
            if (i >= recordLen) {
                return (index, feeAmount, startTime);
            }
            Record storage record = _userRecords[account][i];
            feeAmount[index] = record.feeAmount;
            startTime[index] = record.start;
            index++;
        }
    }

    function getPoolLength() external view returns (uint256){
        return _pools.length;
    }

    function getBaseInfo() external view returns (
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol,
        bool pause, uint256 minAmount, uint256 blockTime
    ){
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        pause = _pause;
        minAmount = _minAmount;
        blockTime = block.timestamp;
    }

    function getUserInfo(address account) external view returns (
        uint256 amount,
        bool active,
        uint256 inviteReward,
        uint256 teamAccount,
        uint256 teamAmount,
        uint256 tokenBalance,
        uint256 tokenAllowance
    ){
        UserInfo storage userInfo = _userInfos[account];
        amount = userInfo.amount;
        active = userInfo.active;
        inviteReward = userInfo.inviteReward;
        teamAccount = userInfo.teamAccount;
        teamAmount = userInfo.teamAmount;
        tokenBalance = IERC20(_tokenAddress).balanceOf(account);
        tokenAllowance = IERC20(_tokenAddress).allowance(account, address(this));
    }

    function claimTeamReward(address account) external {
        uint256 level = getUserLevel(account);
        LevelConfig storage levelConfig;
        uint256 pendingReward;
        uint256 levelReward;
        if (level != MAX) {
            for (uint256 i; i <= level;) {
                levelConfig = _levelConfigs[i];
                if (_userInfos[account].levelClaimed[i] == 0) {
                    if (i == 0) {
                        levelReward = levelConfig.teamAmount * levelConfig.rewardRate / _feeDivFactor;
                    } else {
                        levelReward = (levelConfig.teamAmount - _levelConfigs[i - 1].teamAmount) * levelConfig.rewardRate / _feeDivFactor;
                    }
                    pendingReward += levelReward;
                    _userInfos[account].levelClaimed[i] = levelReward;
                }
            unchecked{
                ++i;
            }
            }
        }
        if (pendingReward > 0) {
            IERC20(_tokenAddress).transfer(account, pendingReward);
        }
    }

    function getUserLevelInfo(address account) external view returns (
        uint256 level, uint256 rewardRate,
        uint256 pendingReward, uint256 claimedReward,
        address invitor, uint256 binderLength
    ){
        level = getUserLevel(account);
        rewardRate = _levelConfigs[level].rewardRate;
        invitor = _invitor[account];
        binderLength = getBinderLength(account);
        LevelConfig storage levelConfig;
        if (level != MAX) {
            for (uint256 i; i <= level;) {
                levelConfig = _levelConfigs[i];
                if (_userInfos[account].levelClaimed[i] == 0) {
                    if (i == 0) {
                        pendingReward += levelConfig.teamAmount * levelConfig.rewardRate / _feeDivFactor;
                    } else {
                        pendingReward += (levelConfig.teamAmount - _levelConfigs[i - 1].teamAmount) * levelConfig.rewardRate / _feeDivFactor;
                    }
                } else {
                    claimedReward += _userInfos[account].levelClaimed[i];
                }
            unchecked{
                ++i;
            }
            }
        }
    }

    function getUserLevel(address account) public view returns (
        uint256 level
    ){
        level = MAX;
        uint256 len = _levelLength;
        UserInfo storage userInfo = _userInfos[account];
        uint256 teamAmount = userInfo.teamAmount;
        uint256 amount = userInfo.amount;
        LevelConfig storage levelConfig;
        for (uint256 i = len; i > 0;) {
        unchecked{
            --i;
        }
            levelConfig = _levelConfigs[i];
            if (teamAmount >= levelConfig.teamAmount && amount >= levelConfig.amount) {
                level = i;
                break;
            }
        }
    }

    function getLevelClaimed(address account, uint256 level) external view returns (uint256){
        return _userInfos[account].levelClaimed[level];
    }

    function getBinderLength(address account) public view returns (uint256){
        return _binder[account].length;
    }

    function getLevelConfig(uint256 level) external view returns (
        uint256 rewardRate,
        uint256 teamAmount,
        uint256 amount
    ){
        LevelConfig storage config = _levelConfigs[level];
        rewardRate = config.rewardRate;
        teamAmount = config.teamAmount;
        amount = config.amount;
    }

    function claimToken(address tokenAddress, address to, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transfer(to, amount);
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        address payable addr = payable(to);
        addr.transfer(amount);
    }

    function setPause(bool p) external onlyOwner {
        _pause = p;
    }

    function addPool(uint256 duration, uint256 rewardRate) external onlyOwner {
        _pools.push(Pool(duration, rewardRate, 0));
    }

    function setPoolReward(uint256 pid, uint256 rewardRate) external onlyOwner {
        _pools[pid].rewardRate = rewardRate;
    }

    function setTokenAddress(address tokenAddress) external onlyOwner {
        _tokenAddress = tokenAddress;
        _amountUnit = 10 ** IERC20(tokenAddress).decimals();
    }

    function setMinAmount(uint256 amount) external onlyOwner {
        _minAmount = amount * _amountUnit;
    }

    function setInviteFee(uint256 level, uint256 fee) external onlyOwner {
        _inviteFee[level] = fee;
    }

    function setTeamLength(uint256 len) external onlyOwner {
        _teamLength = len;
    }

    function setInviteLength(uint256 len) external onlyOwner {
        _inviteLength = len;
    }

    function setLevelLength(uint256 len) external onlyOwner {
        _levelLength = len;
    }

    function setFeeRate(uint256 feeRate) external onlyOwner {
        _feeRate = feeRate;
    }

    function setLevelConfig(
        uint256 level, uint256 rewardRate, uint256 teamAmount, uint256 amount
    ) external onlyOwner {
        _levelConfigs[level].rewardRate = rewardRate;
        _levelConfigs[level].teamAmount = teamAmount;
        _levelConfigs[level].amount = amount;
    }
}

contract UEarnPool is AbsPool {
    constructor() AbsPool(
        address(0x55d398326f99059fF775485246999027B3197955)
    ){

    }
}