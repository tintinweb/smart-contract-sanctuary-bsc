/**
 *Submitted for verification at BscScan.com on 2022-12-15
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
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ISwapPair {
    function token0() external view returns (address);

    function token1() external view returns (address);
}

contract GTMintPool is Ownable {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 lockReward;
        uint256 claimedReward;
        uint256 rewardDebt2;
        bool active;
        address invitor;
        uint256 inviteAmount;
        uint256 inviteReward;
    }

    struct PoolInfo {
        address lpToken;
        uint256 startTime;
        uint256 endTime;
        uint256 totalAmount;
        uint256 lastRewardBlock;
        address rewardToken;
        uint256 rewardPerBlock;
        uint256 accPerShare;
        uint256 accReward;
        uint256 totalReward;
        uint256 releaseTime;
        uint256 releaseDuration;
        uint256 rewardPerBlock2;
        uint256 accPerShare2;
        uint256 accReward2;
        uint256 totalReward2;
    }

    PoolInfo private poolInfo;
    mapping(address => UserInfo) private userInfo;
    mapping(address => uint256) public poolLpBalances;
    mapping(address => bool) public _singleToken;

    mapping(address => address[]) public _binder;
    uint256 public constant _feeDivFactor = 10000;
    uint256 public _inviteFee = 800;
    uint256 public _inviteFee2 = 500;
    uint256 public constant _rewardFactor = 1e18;

    function deposit(uint256 amount, address invitor) external {
        require(amount > 0, "deposit == 0");
        _updatePool();

        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        if (!user.active) {
            user.active = true;
            if (userInfo[invitor].active) {
                user.invitor = invitor;
                _binder[invitor].push(account);
            }
        }

        _claim(user, account);

        PoolInfo storage pool = poolInfo;

        IERC20 lpToken = IERC20(pool.lpToken);
        uint256 beforeAmount = lpToken.balanceOf(address(this));
        lpToken.transferFrom(account, address(this), amount);
        uint256 afterAmount = lpToken.balanceOf(address(this));
        amount = afterAmount - beforeAmount;

        pool.totalAmount += amount;
        poolLpBalances[pool.lpToken] += amount;

        invitor = user.invitor;
        if (invitor != address(0)) {
            userInfo[invitor].inviteAmount += amount;
        }

        uint256 userAmount = user.amount;
        userAmount += amount;
        user.amount = userAmount;
        user.rewardDebt = userAmount * pool.accPerShare / _rewardFactor;
        user.rewardDebt2 = userAmount * pool.accPerShare2 / _rewardFactor;
    }

    function withdraw() public {
        _withdraw(true);
    }

    function _withdraw(bool getReward) private {
        _updatePool();

        address account = msg.sender;
        UserInfo storage user = userInfo[account];

        if (getReward) {
            _claim(user, account);
        }

        uint256 amount = user.amount;

        PoolInfo storage pool = poolInfo;

        IERC20(pool.lpToken).transfer(account, amount);
        pool.totalAmount -= amount;
        poolLpBalances[pool.lpToken] -= amount;

        address invitor = user.invitor;
        if (invitor != address(0)) {
            userInfo[invitor].inviteAmount -= amount;
        }

        uint256 userAmount = user.amount;
        userAmount -= amount;
        user.amount = userAmount;
        user.rewardDebt = userAmount * pool.accPerShare / _rewardFactor;
        user.rewardDebt2 = userAmount * pool.accPerShare2 / _rewardFactor;
    }

    function claim() external {
        _updatePool();
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        _claim(user, account);
    }

    function initPool(
        address lpToken,
        uint256 startTime,
        uint256 endTime,
        uint256 timePerBlock,
        address rewardToken,
        uint256 rewardPerBlock,
        uint256 totalReward
    ) external onlyOwner {
        require(lpToken != address(0), "lpToken");
        require(rewardToken != address(0), "rewardToken");
        require(poolInfo.lpToken == address(0), "init");
        uint256 blockTimestamp = block.timestamp;
        uint256 blockNum = block.number;
        uint256 startBlock;
        if (startTime > blockTimestamp) {
            startBlock = blockNum + (startTime - blockTimestamp) / timePerBlock;
        } else {
            startBlock = blockNum;
        }
        poolInfo = PoolInfo({
        lpToken : lpToken,
        totalAmount : 0,
        lastRewardBlock : startBlock,
        startTime : startTime,
        endTime : endTime,
        rewardToken : rewardToken,
        rewardPerBlock : rewardPerBlock,
        accPerShare : 0,
        accReward : 0,
        totalReward : totalReward,
        releaseTime : 0,
        releaseDuration : 50 days,
        rewardPerBlock2 : 0,
        accPerShare2 : 0,
        accReward2 : 0,
        totalReward2 : 0
        });
    }

    function initReward2(
        uint256 rewardPerBlock2,
        uint256 totalReward2
    ) external onlyOwner {
        _updatePool();
        PoolInfo storage pool = poolInfo;
        pool.rewardPerBlock2 = rewardPerBlock2;
        pool.totalReward2 = totalReward2;
    }

    function setRewardPerBlock(uint256 rewardPerBlock) external onlyOwner {
        _updatePool();
        poolInfo.rewardPerBlock = rewardPerBlock;
    }

    function setRewardPerBlock2(uint256 rewardPerBlock2) external onlyOwner {
        _updatePool();
        poolInfo.rewardPerBlock2 = rewardPerBlock2;
    }

    function setTotalReward(uint256 totalReward) external onlyOwner {
        _updatePool();
        poolInfo.totalReward = totalReward;
    }

    function setTotalReward2(uint256 totalReward2) external onlyOwner {
        _updatePool();
        poolInfo.totalReward2 = totalReward2;
    }

    function setPoolLP(address lp) external onlyOwner {
        PoolInfo storage pool = poolInfo;
        require(pool.totalAmount == 0, "started");
        pool.lpToken = lp;
    }

    function setRewardToken(address token) external onlyOwner {
        PoolInfo storage pool = poolInfo;
        pool.rewardToken = token;
    }

    function setReleaseTime(uint256 time) external onlyOwner {
        PoolInfo storage pool = poolInfo;
        pool.releaseTime = time;
    }

    function setReleaseDuration(uint256 duration) external onlyOwner {
        PoolInfo storage pool = poolInfo;
        pool.releaseDuration = duration;
    }

    function setTime(uint256 startTime, uint256 endTime, uint256 timePerBlock) external onlyOwner {
        PoolInfo storage pool = poolInfo;
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

    function startPool() external onlyOwner {
        uint256 blockNum = block.number;
        PoolInfo storage pool = poolInfo;
        require(pool.lastRewardBlock > blockNum && pool.accReward == 0, "started");
        pool.lastRewardBlock = blockNum;
    }

    receive() external payable {

    }

    function _updatePool() private {
        PoolInfo storage pool = poolInfo;
        uint256 blockNum = block.number;
        uint256 lastRewardBlock = pool.lastRewardBlock;
        if (blockNum <= lastRewardBlock) {
            return;
        }
        pool.lastRewardBlock = blockNum;

        uint256 totalAmount = pool.totalAmount;
        if (0 == totalAmount) {
            return;
        }

        uint256 accReward = pool.accReward;
        uint256 totalReward = pool.totalReward;
        if (accReward < totalReward) {
            uint256 rewardPerBlock = pool.rewardPerBlock;
            if (0 < totalAmount && 0 < rewardPerBlock) {
                uint256 reward = rewardPerBlock * (blockNum - lastRewardBlock);
                uint256 remainReward = totalReward - accReward;
                if (reward > remainReward) {
                    reward = remainReward;
                }
                pool.accPerShare += reward * _rewardFactor / totalAmount;
                pool.accReward += reward;
            }
        }

        _updatePool2(pool, totalAmount, blockNum, lastRewardBlock);
    }

    function _updatePool2(PoolInfo storage pool, uint256 totalAmount, uint256 blockNum, uint256 lastRewardBlock) private {
        uint256 accReward = pool.accReward2;
        uint256 totalReward = pool.totalReward2;
        if (accReward < totalReward) {
            uint256 rewardPerBlock = pool.rewardPerBlock2;
            if (0 < totalAmount && 0 < rewardPerBlock) {
                uint256 reward = rewardPerBlock * (blockNum - lastRewardBlock);
                uint256 remainReward = totalReward - accReward;
                if (reward > remainReward) {
                    reward = remainReward;
                }
                pool.accPerShare2 += reward * _rewardFactor / totalAmount;
                pool.accReward2 += reward;
            }
        }
    }

    function _claim(UserInfo storage user, address account) private {
        PoolInfo storage pool = poolInfo;
        uint256 userAmount = user.amount;
        uint256 lockReward = user.lockReward;
        if (userAmount > 0) {
            uint256 accReward = userAmount * pool.accPerShare / _rewardFactor;
            uint256 pendingAmount = accReward - user.rewardDebt;
            if (pendingAmount > 0) {
                user.rewardDebt = accReward;
                lockReward += pendingAmount;
                user.lockReward = lockReward;
            }
        }

        uint256 reward2 = _claim2(pool, user, userAmount);
        uint256 pendingClaimReward;

        uint256 releaseTime = pool.releaseTime;
        uint256 blockTime = block.timestamp;
        if (0 < releaseTime && blockTime > releaseTime) {
            uint256 releaseReward = lockReward * (blockTime - releaseTime) / pool.releaseDuration;
            if (releaseReward > lockReward) {
                releaseReward = lockReward;
            }
            uint256 claimedReward = user.claimedReward;
            if (releaseReward > claimedReward) {
                pendingClaimReward = releaseReward - claimedReward;
                user.claimedReward += pendingClaimReward;
            }
        }

        uint256 totalReward = reward2 + pendingClaimReward;
        if (totalReward > 0) {
            uint256 inviteReward1 = totalReward * _inviteFee / _feeDivFactor;
            uint256 inviteReward2 = totalReward * _inviteFee2 / _feeDivFactor;

            IERC20 rewardToken = IERC20(pool.rewardToken);
            require(rewardToken.balanceOf(address(this)) >= totalReward + inviteReward1 + inviteReward2, "rewardToken not enough");
            rewardToken.transfer(account, totalReward);

            address invitor1 = user.invitor;
            if (address(0) != invitor1) {
                if (inviteReward1 > 0) {
                    userInfo[invitor1].inviteReward += inviteReward1;
                    rewardToken.transfer(invitor1, inviteReward1);
                }
                address invitor2 = userInfo[invitor1].invitor;
                if (address(0) != invitor2 && inviteReward2 > 0) {
                    userInfo[invitor2].inviteReward += inviteReward2;
                    rewardToken.transfer(invitor2, inviteReward2);
                }
            }
        }
    }

    function _claim2(PoolInfo storage pool, UserInfo storage user, uint256 userAmount) private returns (uint256 pendingAmount){
        uint256 accReward = userAmount * pool.accPerShare2 / _rewardFactor;
        pendingAmount = accReward - user.rewardDebt2;
        if (pendingAmount > 0) {
            user.rewardDebt2 = accReward;
        }
    }

    function _pendingReward(address account) private view returns (
        uint256 reward, uint256 reward2
    ) {
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[account];
        uint256 amount = user.amount;

        if (amount > 0) {
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
            uint256 totalAmount = pool.totalAmount;
            reward = user.amount * (pool.accPerShare + poolPendingReward * _rewardFactor / totalAmount) / _rewardFactor - user.rewardDebt;

            reward2 = _pendingReward2(pool, user, blockNum, lastRewardBlock, totalAmount, amount);
        }
    }

    function _pendingReward2(
        PoolInfo storage pool, UserInfo storage user, uint256 blockNum, uint256 lastRewardBlock, uint256 totalAmount, uint256 amount
    ) private view returns (uint256 reward) {
        uint256 poolPendingReward;
        if (blockNum > lastRewardBlock) {
            poolPendingReward = pool.rewardPerBlock2 * (blockNum - lastRewardBlock);
            uint256 totalReward = pool.totalReward2;
            uint256 accReward = pool.accReward2;
            uint256 remainReward;
            if (totalReward > accReward) {
                remainReward = totalReward - accReward;
            }
            if (poolPendingReward > remainReward) {
                poolPendingReward = remainReward;
            }
        }
        reward = amount * (pool.accPerShare2 + poolPendingReward * _rewardFactor / totalAmount) / _rewardFactor - user.rewardDebt2;
    }

    function getPoolInfo() public view returns (
        address lpToken,
        uint256 startTime,
        uint256 endTime,
        uint256 totalAmount,
        uint256 lastRewardBlock,
        uint256 lpTokenDecimals,
        string memory lpToken0Symbol,
        string memory lpToken1Symbol
    ) {
        PoolInfo storage pool = poolInfo;
        lpToken = pool.lpToken;
        startTime = pool.startTime;
        endTime = pool.endTime;
        totalAmount = pool.totalAmount;
        lastRewardBlock = pool.lastRewardBlock;
        lpTokenDecimals = IERC20(pool.lpToken).decimals();
        if (_singleToken[pool.lpToken]) {
            lpToken0Symbol = IERC20(pool.lpToken).symbol();
            lpToken1Symbol = IERC20(pool.lpToken).symbol();
        } else {
            lpToken0Symbol = IERC20(ISwapPair(pool.lpToken).token0()).symbol();
            lpToken1Symbol = IERC20(ISwapPair(pool.lpToken).token1()).symbol();
        }
    }

    function getPoolRewardInfo() public view returns (
        address rewardToken,
        uint256 rewardPerBlock,
        uint256 accPerShare,
        uint256 accReward,
        uint256 totalReward,
        uint256 rewardTokenDecimals,
        string memory rewardTokenSymbol,
        uint256 releaseTime,
        uint256 releaseDuration
    ) {
        PoolInfo storage pool = poolInfo;
        rewardToken = pool.rewardToken;
        rewardPerBlock = pool.rewardPerBlock;
        accPerShare = pool.accPerShare;
        accReward = pool.accReward;
        totalReward = pool.totalReward;
        if (address(0) != rewardToken) {
            rewardTokenDecimals = IERC20(rewardToken).decimals();
            rewardTokenSymbol = IERC20(rewardToken).symbol();
        }
        releaseTime = pool.releaseTime;
        releaseDuration = pool.releaseDuration;
    }

    function getPoolRewardInfo2() public view returns (
        uint256 rewardPerBlock,
        uint256 accPerShare,
        uint256 accReward,
        uint256 totalReward,
        uint256 timestamp,
        uint256 blockNum
    ) {
        PoolInfo storage pool = poolInfo;
        rewardPerBlock = pool.rewardPerBlock2;
        accPerShare = pool.accPerShare2;
        accReward = pool.accReward2;
        totalReward = pool.totalReward2;
        timestamp = block.timestamp;
        blockNum = block.number;
    }

    function getUserInfo(address account) public view returns (
        uint256 amount,
        uint256 pending,
        uint256 pending2,
        uint256 lockReward,
        uint256 claimedReward,
        uint256 releaseReward
    ) {
        UserInfo storage user = userInfo[account];
        amount = user.amount;
        (pending, pending2) = _pendingReward(account);
        lockReward = user.lockReward;
        claimedReward = user.claimedReward;

        uint256 totalLockReward = pending + lockReward;
        PoolInfo storage pool = poolInfo;
        uint256 releaseTime = pool.releaseTime;
        uint256 blockTime = block.timestamp;
        if (0 < releaseTime && blockTime > releaseTime) {
            releaseReward = totalLockReward * (blockTime - releaseTime) / pool.releaseDuration;
            if (releaseReward > totalLockReward) {
                releaseReward = totalLockReward;
            }
        }
    }

    function getUserExtInfo(address account) public view returns (
        uint256 lpBalance,
        uint256 lpAllowance,
        bool active,
        address invitor,
        uint256 binderLength,
        uint256 inviteAmount,
        uint256 inviteReward,
        uint256 rewardDebt,
        uint256 rewardDebt2
    ) {
        lpBalance = IERC20(poolInfo.lpToken).balanceOf(account);
        lpAllowance = IERC20(poolInfo.lpToken).allowance(account, address(this));
        UserInfo storage user = userInfo[account];
        active = user.active;
        invitor = user.invitor;
        binderLength = _binder[account].length;
        inviteAmount = user.inviteAmount;
        inviteReward = user.inviteReward;
        rewardDebt = user.rewardDebt;
        rewardDebt2 = user.rewardDebt2;
    }

    function emergencyWithdraw() external {
        _withdraw(false);
    }

    function setSingleToken(address token, bool enable) external onlyOwner {
        _singleToken[token] = enable;
    }

    function setInviteFee(uint256 fee) external onlyOwner {
        _inviteFee = fee;
    }

    function setInviteFee2(uint256 fee) external onlyOwner {
        _inviteFee2 = fee;
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(address token, address to, uint256 amount) external onlyOwner {
        uint256 maxClaim = IERC20(token).balanceOf(address(this)) - poolLpBalances[token];
        if (amount > maxClaim) {
            amount = maxClaim;
        }
        IERC20(token).transfer(to, amount);
    }
}