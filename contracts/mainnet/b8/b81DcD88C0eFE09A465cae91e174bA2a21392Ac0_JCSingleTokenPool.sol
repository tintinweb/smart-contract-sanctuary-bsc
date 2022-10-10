/**
 *Submitted for verification at BscScan.com on 2022-10-10
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
        uint256 rewardPerToken;
        uint256 lockAmount;
        uint256 reward;
    }

    struct Record {
        uint256 pid;
        uint256 amount;
        uint256 reward;
        uint256 start;
        uint256 duration;
        uint256 status;
    }

    address private _lockTokenAddress;
    address private _rewardTokenAddress;
    Pool[] private _pools;

    mapping(address => Record[]) private _userRecords;
    bool private _pause;

    function lock(uint256 pid, uint256 amount) external {
        require(!_pause, "Pause");
        require(amount > 0, "=0");
        address account = msg.sender;
        IERC20(_lockTokenAddress).transferFrom(account, address(this), amount);
        Pool storage pool = _pools[pid];
        uint256 reward = amount * pool.rewardPerToken / (10 ** IERC20(_lockTokenAddress).decimals());
        _userRecords[account].push(
            Record(pid, amount, reward, block.timestamp, pool.duration, 0)
        );
        pool.lockAmount += amount;
        pool.reward += reward;
    }

    function unlock(uint256 index) external {
        address account = msg.sender;
        Record storage record = _userRecords[account][index];
        require(0 == record.status, "had unlock");
        require(block.timestamp >= record.start + record.duration, "not reach time");
        record.status = 1;
        uint256 amount = record.amount;
        uint256 reward = record.reward;
        IERC20(_lockTokenAddress).transfer(account, amount);
        IERC20(_rewardTokenAddress).transfer(account, reward);
        Pool storage pool = _pools[record.pid];
        pool.lockAmount -= amount;
        pool.reward -= reward;
    }

    function allPoolInfo() external view returns (uint256[] memory duration, uint256[] memory rewardPerToken, uint256[] memory lockAmount, uint256[] memory pendingReward){
        uint256 allLength = _pools.length;
        duration = new uint256[](allLength);
        rewardPerToken = new uint256[](allLength);
        lockAmount = new uint256[](allLength);
        pendingReward = new uint256[](allLength);
        for (uint256 i; i < allLength; ++i) {
            (duration[i], rewardPerToken[i], lockAmount[i], pendingReward[i]) = getPoolInfo(i);
        }
    }

    function getPoolInfo(uint256 pid) public view returns (uint256 duration, uint256 rewardPerToken, uint256 lockAmount, uint256 pendingReward){
        Pool storage pool = _pools[pid];
        duration = pool.duration;
        rewardPerToken = pool.rewardPerToken;
        lockAmount = pool.lockAmount;
        pendingReward = pool.reward;
    }

    function getRecordLength(address account) public view returns (uint256){
        return _userRecords[account].length;
    }

    function getRecordInfo(address account, uint256 i) public view returns (
        uint256 pid,
        uint256 amount,
        uint256 reward,
        uint256 startTime,
        uint256 duration,
        uint256 status
    ){
        Record storage record = _userRecords[account][i];
        pid = record.pid;
        amount = record.amount;
        reward = record.reward;
        startTime = record.start;
        duration = record.duration;
        status = record.status;
    }

    function getRecords(
        address account,
        uint256 start,
        uint256 length
    )
    external
    view
    returns (
        uint256 returnedCount,
        uint256[] memory pid,
        uint256[] memory amount,
        uint256[] memory reward,
        uint256[] memory startTime,
        uint256[] memory duration,
        uint256[] memory status
    )
    {
        uint256 recordLen = _userRecords[account].length;
        if (0 == length) {
            length = recordLen;
        }
        returnedCount = length;
        pid = new uint256[](length);
        amount = new uint256[](length);
        reward = new uint256[](length);
        startTime = new uint256[](length);
        duration = new uint256[](length);
        status = new uint256[](length);
        uint256 index = 0;
        for (uint256 i = start; i < start + length; i++) {
            if (i >= recordLen) {
                return (index, pid, amount, reward, startTime, duration, status);
            }
            (
            pid[index],
            amount[index],
            reward[index],
            startTime[index],
            duration[index],
            status[index]
            ) = getRecordInfo(account, i);
            index++;
        }
    }

    function getUserInfo(address account) external view returns (
        uint256 lockTokenBalance,
        uint256 lockTokenAllowance,
        uint256 rewardTokenBalance
    ){
        lockTokenBalance = IERC20(_lockTokenAddress).balanceOf(account);
        lockTokenAllowance = IERC20(_lockTokenAddress).allowance(account, address(this));
        rewardTokenBalance = IERC20(_rewardTokenAddress).balanceOf(account);
    }

    function getBaseInfo() public view returns (
        uint256 poolLength, uint256 blockTime, bool isPause,
        address lockToken, uint256 lockTokenDecimals, string memory lockTokenSymbol,
        address rewardToken, uint256 rewardTokenDecimals, string memory rewardTokenSymbol
    ){
        poolLength = _pools.length;
        blockTime = block.timestamp;
        isPause = _pause;
        lockToken = _lockTokenAddress;
        lockTokenDecimals = IERC20(lockToken).decimals();
        lockTokenSymbol = IERC20(lockToken).symbol();
        rewardToken = _rewardTokenAddress;
        rewardTokenDecimals = IERC20(rewardToken).decimals();
        rewardTokenSymbol = IERC20(rewardToken).symbol();
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(address token, address to, uint256 amount) external onlyOwner {
        if (token == _lockTokenAddress) {
            return;
        }
        IERC20(token).transfer(to, amount);
    }

    function setPause(bool p) external onlyOwner {
        _pause = p;
    }

    function setLockToken(address token) external onlyOwner {
        _lockTokenAddress = token;
    }

    function setRewardToken(address token) external onlyOwner {
        _rewardTokenAddress = token;
    }

    function setReward(uint256 pid, uint256 rewardPerToken) external onlyOwner {
        _pools[pid].rewardPerToken = rewardPerToken;
    }

    function setDuration(uint256 pid, uint256 duration) external onlyOwner {
        _pools[pid].duration = duration;
    }

    function addPool(uint256 duration, uint256 rewardPerToken) external onlyOwner {
        _pools.push(Pool(duration, rewardPerToken, 0, 0));
    }

    constructor(
        address LockTokenAddress, address RewardTokenAddress,
        uint256 reward7, uint256 reward15, uint256 reward30, uint256 reward60
    ){
        _lockTokenAddress = LockTokenAddress;
        _rewardTokenAddress = RewardTokenAddress;
        uint256 rewardUnit = 10 ** IERC20(RewardTokenAddress).decimals();
        _pools.push(Pool(7 days, reward7 * rewardUnit, 0, 0));
        _pools.push(Pool(15 days, reward15 * rewardUnit, 0, 0));
        _pools.push(Pool(30 days, reward30 * rewardUnit, 0, 0));
        _pools.push(Pool(60 days, reward60 * rewardUnit, 0, 0));
    }
}

contract JCSingleTokenPool is AbsPool {
    constructor() AbsPool(
    //JC
        address(0x81B89eA9CfA4787FA1ee3C96217746764681d7D4),
    //TJ
        address(0x451D8d18759916b091a66F9B669a0FFE567D8322),
        1, 3, 14, 30
    ){

    }
}