/**
 *Submitted for verification at BscScan.com on 2022-07-01
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

contract StarSwapLPPool is Ownable {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        address lpToken;
        address rewardToken;
        uint256 rewardPerBlock;
        uint256 lastRewardBlock;
        uint256 accPerShare;
        uint256 totalAmount;
        uint256 accReward;
        uint256 startBlock;
        uint256 endBlock;
        uint256 perMaxReward;
        uint256 inviteFee;
        uint256 inviteFee1;
        uint256 startTime;
        uint256 endTime;
    }

    PoolInfo[] private poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) private userInfo;
    address public receiveAddress;
    mapping(address => uint256) public poolLpBalances;
    mapping(uint256 => mapping(address => uint256)) public _inviteReward;
    mapping(address => address) public _inviter;
    mapping(address => address[]) public _binders;
    address[] public _userList;
    mapping(address => uint256) public _depositNum;

    constructor(){
        receiveAddress = msg.sender;
        _depositNum[address(0x937F7069e5AB21de4cD667Ec365FD05a958D9828)] = 1;
    }

    function poolLength() public view returns (uint256) {
        return poolInfo.length;
    }


    function deposit(uint256 pid, uint256 amount, address invitor) external {
        require(amount > 0, "deposit == 0");
        address account = msg.sender;
        if (_depositNum[account] == 0) {
            require(address(0) != invitor, "invitor == 0");
            require(_depositNum[invitor] > 0, "invitor not active");
            _userList.push(account);
            _inviter[account] = invitor;
            _binders[invitor].push(account);
        }

        _updatePool(pid);

        UserInfo storage user = userInfo[pid][account];
        _claim(pid, user, account);

        PoolInfo storage pool = poolInfo[pid];
        IERC20(pool.lpToken).transferFrom(account, address(this), amount);
        user.amount += amount;
        pool.totalAmount += amount;
        poolLpBalances[pool.lpToken] += amount;
        _depositNum[account] += 1;
        user.rewardDebt = user.amount * pool.accPerShare / 1e12;
    }

    function withdraw(uint256 pid, uint256 amount) public {
        _updatePool(pid);

        address account = msg.sender;
        UserInfo storage user = userInfo[pid][account];
        if (amount > user.amount) {
            amount = user.amount;
        }
        _claim(pid, user, account);
        PoolInfo storage pool = poolInfo[pid];
        if (amount > 0) {
            IERC20(pool.lpToken).transfer(account, amount);
            user.amount -= amount;
            pool.totalAmount -= amount;
            poolLpBalances[pool.lpToken] -= amount;
        }
        user.rewardDebt = user.amount * pool.accPerShare / 1e12;
    }

    function claim(uint256 pid) external {
        withdraw(pid, 0);
    }

    function addPool(
        address lpToken,
        address rewardToken,
        uint256 rewardPerBlock,
        uint256 startTime,
        uint256 endTime,
        uint256 perMaxReward,
        uint256 inviteFee,
        uint256 inviteFee1,
        uint256 timePerBlock
    ) external onlyOwner {
        uint256 blockTimestamp = block.timestamp;
        uint256 blockNum = block.number;
        uint256 startBlock;
        if (startTime > blockTimestamp) {
            startBlock = blockNum + (startTime - blockTimestamp) / timePerBlock;
        } else {
            startBlock = blockNum;
        }
        require(endTime > blockTimestamp, "endTime <= blockTimestamp");
        uint256 endBlock = blockNum + (endTime - blockTimestamp) / timePerBlock;
        require(startBlock < endBlock, "startBlock >= endBlock");
        poolInfo.push(PoolInfo({
        lpToken : lpToken,
        rewardToken : rewardToken,
        rewardPerBlock : rewardPerBlock,
        lastRewardBlock : startBlock,
        accPerShare : 0,
        totalAmount : 0,
        accReward : 0,
        startBlock : startBlock,
        endBlock : endBlock,
        perMaxReward : perMaxReward,
        inviteFee : inviteFee,
        inviteFee1 : inviteFee1,
        startTime : startTime,
        endTime : endTime
        }));
    }

    function setPoolRewardPerBlock(uint256 pid, uint256 rewardPerBlock) external onlyOwner {
        _updatePool(pid);
        poolInfo[pid].rewardPerBlock = rewardPerBlock;
    }

    function setPoolPerMaxReward(uint256 pid, uint256 perMaxReward) external onlyOwner {
        _updatePool(pid);
        poolInfo[pid].perMaxReward = perMaxReward;
    }

    function setPoolInviteFee(uint256 pid, uint256 inviteFee, uint256 inviteFee1) external onlyOwner {
        _updatePool(pid);
        poolInfo[pid].inviteFee = inviteFee;
        poolInfo[pid].inviteFee1 = inviteFee1;
    }

    receive() external payable {

    }

    function _updatePool(uint256 pid) private {
        PoolInfo storage pool = poolInfo[pid];
        uint256 blockNum = block.number;
        if (blockNum <= pool.lastRewardBlock || pool.lastRewardBlock >= pool.endBlock) {
            return;
        }
        if (blockNum > pool.endBlock) {
            blockNum = pool.endBlock;
        }
        if (0 < pool.totalAmount && 0 < pool.rewardPerBlock) {
            uint256 reward = pool.rewardPerBlock * (blockNum - pool.lastRewardBlock);
            pool.accPerShare += reward * 1e12 / pool.totalAmount;
            pool.accReward += reward;
        }
        pool.lastRewardBlock = blockNum;
    }

    function _claim(uint256 pid, UserInfo storage user, address account) private {
        PoolInfo memory pool = poolInfo[pid];
        uint256 userAmount = user.amount;
        if (userAmount > 0) {
            uint256 pendingAmount = userAmount * pool.accPerShare / 1e12 - user.rewardDebt;
            if (pendingAmount > 0) {
                user.rewardDebt = userAmount * pool.accPerShare / 1e12;
                IERC20 rewardToken = IERC20(pool.rewardToken);
                if (pendingAmount > pool.perMaxReward) {
                    pendingAmount = pool.perMaxReward;
                }
                uint256 inviteReward = pendingAmount * pool.inviteFee / 100;
                uint256 inviteReward1 = pendingAmount * pool.inviteFee1 / 100;
                require(rewardToken.balanceOf(address(this)) >= pendingAmount + inviteReward + inviteReward1, "rewardToken not enough");
                rewardToken.transfer(account, pendingAmount);

                require(account == tx.origin, "not origin");
                address invitor = _inviter[account];
                if (address(0) != invitor) {
                    uint256 invitorAmount = userInfo[pid][invitor].amount;
                    if (invitorAmount < userAmount) {
                        inviteReward = inviteReward * invitorAmount / userAmount;
                    }
                    if (inviteReward > 0) {
                        rewardToken.transfer(invitor, inviteReward);
                        _inviteReward[pid][invitor] += inviteReward;
                    }

                    invitor = _inviter[invitor];
                    if (address(0) != invitor) {
                        invitorAmount = userInfo[pid][invitor].amount;
                        if (invitorAmount < userAmount) {
                            inviteReward1 = inviteReward1 * invitorAmount / userAmount;
                        }
                        if (inviteReward1 > 0) {
                            rewardToken.transfer(invitor, inviteReward1);
                            _inviteReward[pid][invitor] += inviteReward1;
                        }
                    }
                }
            }
        }
    }
    function _pendingReward(uint256 pid, address account) private view returns (uint256 reward) {
        reward = 0;
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][account];
        if (user.amount > 0) {
            uint256 poolPendingBlockNum;
            uint256 blockNum = block.number;
            if (blockNum > pool.lastRewardBlock) {
                if (blockNum > pool.endBlock) {
                    blockNum = pool.endBlock;
                }
                poolPendingBlockNum = blockNum - pool.lastRewardBlock;
            }
            uint256 poolPendingReward = pool.rewardPerBlock * poolPendingBlockNum;
            reward = user.amount * (pool.accPerShare + poolPendingReward * 1e12 / pool.totalAmount) / 1e12 - user.rewardDebt;
        }
        if (reward > pool.perMaxReward) {
            reward = pool.perMaxReward;
        }
    }

    function getPoolInfo(uint256 pid) public view returns (address lpToken, address rewardToken, uint256 rewardPerBlock, uint256 amount, uint256 reward, uint256 startTime, uint256 endTime) {
        PoolInfo memory pool = poolInfo[pid];
        lpToken = pool.lpToken;
        rewardToken = pool.rewardToken;
        rewardPerBlock = pool.rewardPerBlock;
        amount = pool.totalAmount;
        reward = pool.accReward;
        startTime = pool.startTime;
        endTime = pool.endTime;
    }

    function getPoolExtraInfo(uint256 pid) public view returns (uint256 perMaxReward, uint256 inviteFee, uint256 inviteFee1, uint256 startBlock, uint256 endBlock) {
        PoolInfo memory pool = poolInfo[pid];
        perMaxReward = pool.perMaxReward;
        inviteFee = pool.inviteFee;
        inviteFee1 = pool.inviteFee1;
        startBlock = pool.startBlock;
        endBlock = pool.endBlock;
    }

    function getUserInfo(uint256 pid, address account) public view returns (uint256 amount, uint256 pending, uint256 inviteReward) {
        UserInfo memory user = userInfo[pid][account];
        amount = user.amount;
        pending = _pendingReward(pid, account);
        inviteReward = _inviteReward[pid][account];
    }

    function getUserInviteInfo(address account) public view returns (address invitor, uint256 binderCount, uint256 depositNum) {
        invitor = _inviter[account];
        binderCount = _binders[account].length;
        depositNum = _depositNum[account];
    }

    function userListLength() external view returns (uint256 length) {
        length = _userList.length;
    }

    function emergencyWithdraw(uint256 pid) external {
        _updatePool(pid);
        PoolInfo storage pool = poolInfo[pid];
        address account = msg.sender;
        UserInfo storage user = userInfo[pid][account];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        IERC20(pool.lpToken).transfer(account, amount);
        pool.totalAmount -= amount;
        poolLpBalances[pool.lpToken] -= amount;
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