/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

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
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ISwapPair {
    function token0() external view returns (address);

    function token1() external view returns (address);
}

contract MintPool is Ownable {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 claimedReward;
    }

    struct PoolInfo {
        address lpToken;
        address rewardToken;
        uint256 rewardPerBlock;
        uint256 lastRewardBlock;
        uint256 accPerShare;
        uint256 totalAmount;
        uint256 accReward;
        uint256 startTime;
        uint256 endTime;
        uint256 claimedReward;
        uint256 totalReward;
        uint256 lockDuration;
    }

    struct Record {
        uint256 amount;
        uint256 start;
        uint256 end;
        uint256 status;
    }

    PoolInfo[] private poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) private userInfo;
    address public receiveAddress;
    mapping(address => uint256) public poolLpBalances;
    mapping(address => bool) public _singleToken;
    // id -> address -> record indexes
    mapping(uint256 => mapping(address => Record[])) private userRecords;

    constructor(){
        receiveAddress = msg.sender;
    }

    function poolLength() public view returns (uint256) {
        return poolInfo.length;
    }

    function deposit(uint256 pid, uint256 amount) external {
        require(amount > 0, "deposit == 0");
        _updatePool(pid);

        address account = msg.sender;
        UserInfo storage user = userInfo[pid][account];
        _claim(pid, user, account);

        PoolInfo storage pool = poolInfo[pid];

        IERC20 lpToken = IERC20(pool.lpToken);
        uint256 beforeAmount = lpToken.balanceOf(address(this));
        lpToken.transferFrom(account, address(this), amount);
        uint256 afterAmount = lpToken.balanceOf(address(this));
        amount = afterAmount - beforeAmount;

        user.amount += amount;
        pool.totalAmount += amount;
        poolLpBalances[pool.lpToken] += amount;
        user.rewardDebt = user.amount * pool.accPerShare / 1e12;

        userRecords[pid][account].push(
            Record(amount, block.timestamp, block.timestamp + pool.lockDuration, 0)
        );
    }

    function withdraw(uint256 pid, uint256 index) public {
        _withdraw(pid, index, true);
    }

    function _withdraw(uint256 pid, uint256 index, bool getReward) private {
        _updatePool(pid);

        address account = msg.sender;
        UserInfo storage user = userInfo[pid][account];

        if (getReward) {
            _claim(pid, user, account);
        }

        Record storage record = userRecords[pid][account][index];

        require(0 == record.status, "had unlock");
        require(block.timestamp >= record.end, "not reach time");
        record.status = 1;

        uint256 amount = record.amount;

        PoolInfo storage pool = poolInfo[pid];

        IERC20(pool.lpToken).transfer(account, amount);
        user.amount -= amount;
        pool.totalAmount -= amount;
        poolLpBalances[pool.lpToken] -= amount;

        user.rewardDebt = user.amount * pool.accPerShare / 1e12;
    }

    function claim(uint256 pid) external {
        _updatePool(pid);
        address account = msg.sender;
        UserInfo storage user = userInfo[pid][account];
        _claim(pid, user, account);
    }

    function addPool(
        address lpToken,
        address rewardToken,
        uint256 rewardPerBlock,
        uint256 startTime,
        uint256 endTime,
        uint256 timePerBlock,
        uint256 totalReward,
        uint256 lockDuration
    ) external onlyOwner {
        uint256 blockTimestamp = block.timestamp;
        uint256 blockNum = block.number;
        uint256 startBlock;
        if (startTime > blockTimestamp) {
            startBlock = blockNum + (startTime - blockTimestamp) / timePerBlock;
        } else {
            startBlock = blockNum;
        }
        poolInfo.push(PoolInfo({
        lpToken : lpToken,
        rewardToken : rewardToken,
        rewardPerBlock : rewardPerBlock,
        lastRewardBlock : startBlock,
        accPerShare : 0,
        totalAmount : 0,
        accReward : 0,
        startTime : startTime,
        endTime : endTime,
        claimedReward : 0,
        totalReward : totalReward,
        lockDuration : lockDuration
        }));
    }

    function setPoolLockDuration(uint256 pid, uint256 lockDuration) external onlyOwner {
        poolInfo[pid].lockDuration = lockDuration;
    }

    function setPoolRewardPerBlock(uint256 pid, uint256 rewardPerBlock) external onlyOwner {
        _updatePool(pid);
        poolInfo[pid].rewardPerBlock = rewardPerBlock;
    }

    function setPoolTotalReward(uint256 pid, uint256 totalReward) external onlyOwner {
        _updatePool(pid);
        poolInfo[pid].totalReward = totalReward;
    }

    function setPoolLP(uint256 pid, address lp) external onlyOwner {
        PoolInfo storage pool = poolInfo[pid];
        require(pool.totalAmount == 0, "started");
        pool.lpToken = lp;
    }

    function setPoolRewardToken(uint256 pid, address token) external onlyOwner {
        PoolInfo storage pool = poolInfo[pid];
        pool.rewardToken = token;
    }

    function setPoolTime(uint256 pid, uint256 startTime, uint256 endTime, uint256 timePerBlock) external onlyOwner {
        PoolInfo storage pool = poolInfo[pid];
        pool.startTime = startTime;
        pool.endTime = endTime;

        uint256 blockNum = block.number;
        if (pool.lastRewardBlock > blockNum && pool.accReward == 0) {
            uint256 blockTimestamp = block.timestamp;
            uint256 startBlock;
            if (startTime > blockTimestamp) {
                startBlock = blockNum + (startTime - blockTimestamp) / timePerBlock;
            } else {
                startBlock = blockNum;
            }
            pool.lastRewardBlock = startBlock;
        }
    }

    function startPool(uint256 pid) external onlyOwner {
        uint256 blockNum = block.number;
        PoolInfo storage pool = poolInfo[pid];
        require(pool.lastRewardBlock > blockNum && pool.accReward == 0, "started");
        pool.lastRewardBlock = blockNum;
    }

    receive() external payable {

    }

    function _updatePool(uint256 pid) private {
        PoolInfo storage pool = poolInfo[pid];
        uint256 blockNum = block.number;
        uint256 lastRewardBlock = pool.lastRewardBlock;
        if (blockNum <= lastRewardBlock) {
            return;
        }
        pool.lastRewardBlock = blockNum;

        uint256 accReward = pool.accReward;
        uint256 totalReward = pool.totalReward;
        if (accReward >= totalReward) {
            return;
        }

        uint256 totalAmount = pool.totalAmount;
        uint256 rewardPerBlock = pool.rewardPerBlock;
        if (0 < totalAmount && 0 < rewardPerBlock) {
            uint256 reward = rewardPerBlock * (blockNum - lastRewardBlock);
            uint256 remainReward = totalReward - accReward;
            if (reward > remainReward) {
                reward = remainReward;
            }
            pool.accPerShare += reward * 1e12 / totalAmount;
            pool.accReward += reward;
        }
    }

    function _claim(uint256 pid, UserInfo storage user, address account) private {
        PoolInfo storage pool = poolInfo[pid];
        uint256 userAmount = user.amount;
        if (userAmount > 0) {
            uint256 accReward = userAmount * pool.accPerShare / 1e12;
            uint256 pendingAmount = accReward - user.rewardDebt;
            if (pendingAmount > 0) {
                user.rewardDebt = accReward;
                IERC20 rewardToken = IERC20(pool.rewardToken);
                require(rewardToken.balanceOf(address(this)) >= pendingAmount, "rewardToken not enough");
                rewardToken.transfer(account, pendingAmount);
                require(account == tx.origin, "not origin");
                user.claimedReward += pendingAmount;
                pool.claimedReward += pendingAmount;
            }
        }
    }

    function _pendingReward(uint256 pid, address account) private view returns (uint256 reward) {
        reward = 0;
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][account];
        if (user.amount > 0) {
            uint256 poolPendingReward;
            uint256 blockNum = block.number;
            uint256 lastRewardBlock = pool.lastRewardBlock;
            if (blockNum > lastRewardBlock) {
                poolPendingReward = pool.rewardPerBlock * (blockNum - lastRewardBlock);
                uint256 totalReward = pool.totalReward;
                uint256 accReward = pool.accReward;
                uint256 remainReward;
                if (totalReward > accReward) {
                    remainReward = totalReward - accReward;
                }
                if (poolPendingReward > remainReward) {
                    poolPendingReward = remainReward;
                }
            }
            reward = user.amount * (pool.accPerShare + poolPendingReward * 1e12 / pool.totalAmount) / 1e12 - user.rewardDebt;
        }
    }

    function getPoolInfo(uint256 pid) public view returns (
        address lpToken, address rewardToken, uint256 rewardPerBlock,
        uint256 amount,  uint256 lockDuration
    ) {
        PoolInfo storage pool = poolInfo[pid];
        lpToken = pool.lpToken;
        rewardToken = pool.rewardToken;
        rewardPerBlock = pool.rewardPerBlock;
        amount = pool.totalAmount;
        lockDuration = pool.lockDuration;
    }

    function getPoolData(uint256 pid) public view returns (
        uint256 reward, uint256 totalReward, uint256 claimed
    ) {
        PoolInfo storage pool = poolInfo[pid];
        reward = pool.accReward;
        totalReward = pool.totalReward;
        claimed = pool.claimedReward;
    }

    function getPoolTime(uint256 pid) public view returns (
        uint256 startTime, uint256 endTime
    ) {
        PoolInfo storage pool = poolInfo[pid];
        startTime = pool.startTime;
        endTime = pool.endTime;
    }

    function getPoolExtInfo(uint256 pid) public view returns (
        uint256 rewardTokenDecimals, string memory rewardTokenSymbol, uint256 rewardTokenBalance,
        uint256 lpTokenDecimals, string memory lpToken0Symbol, string memory lpToken1Symbol
    ) {
        PoolInfo storage pool = poolInfo[pid];

        rewardTokenDecimals = IERC20(pool.rewardToken).decimals();
        rewardTokenBalance = IERC20(pool.rewardToken).balanceOf(address(this));
        rewardTokenSymbol = IERC20(pool.rewardToken).symbol();

        lpTokenDecimals = IERC20(pool.lpToken).decimals();
        if (_singleToken[pool.lpToken]) {
            lpToken0Symbol = IERC20(pool.lpToken).symbol();
            lpToken1Symbol = IERC20(pool.lpToken).symbol();
        } else {
            lpToken0Symbol = IERC20(ISwapPair(pool.lpToken).token0()).symbol();
            lpToken1Symbol = IERC20(ISwapPair(pool.lpToken).token1()).symbol();
        }
    }

    function getBlockInfo(uint256 pid) public view returns (
        uint256 timestamp, uint256 blockNum,
        uint256 lastRewardBlock
    ) {
        timestamp = block.timestamp;
        blockNum = block.number;
        PoolInfo memory pool = poolInfo[pid];
        lastRewardBlock = pool.lastRewardBlock;
    }

    function getUserInfo(uint256 pid, address account) public view returns (uint256 amount, uint256 pending, uint256 claimed, uint256 lpBalance) {
        UserInfo memory user = userInfo[pid][account];
        amount = user.amount;
        pending = _pendingReward(pid, account);
        claimed = user.claimedReward;
        lpBalance = IERC20(poolInfo[pid].lpToken).balanceOf(account);
    }

    function getRecords(
        uint256 pid,
        address account,
        uint256 start,
        uint256 length
    )
    external
    view
    returns (
        uint256 returnedCount,
        uint256[] memory amount,
        uint256[] memory startTime,
        uint256[] memory endTime,
        uint256[] memory status
    )
    {
        uint256 recordLen = userRecords[pid][account].length;
        if (0 == length) {
            length = recordLen;
        }
        returnedCount = length;
        amount = new uint256[](length);
        startTime = new uint256[](length);
        endTime = new uint256[](length);
        status = new uint256[](length);
        uint256 index = 0;
        Record storage record;
        for (uint256 i = start; i < start + length; i++) {
            if (i >= recordLen) {
                return (index, amount, startTime, endTime, status);
            }
            record = userRecords[pid][account][i];
            amount[index] = record.amount;
            startTime[index] = record.start;
            endTime[index] = record.end;
            status[index] = record.status;
            index++;
        }
    }

    function emergencyWithdraw(uint256 pid, uint256 index) external {
        _withdraw(pid, index, false);
    }

    function setSingleToken(address token, bool enable) external onlyOwner {
        _singleToken[token] = enable;
    }

    function setReceiveAddress(address addr) external onlyOwner {
        receiveAddress = addr;
    }

    function claimBalance(uint256 amount) external onlyOwner {
        payable(receiveAddress).transfer(amount);
    }

    function claimToken(address token, uint256 amount) external onlyOwner {
        uint256 maxClaim = IERC20(token).balanceOf(address(this)) - poolLpBalances[token];
        if (amount > maxClaim) {
            amount = maxClaim;
        }
        IERC20(token).transfer(receiveAddress, amount);
    }
}