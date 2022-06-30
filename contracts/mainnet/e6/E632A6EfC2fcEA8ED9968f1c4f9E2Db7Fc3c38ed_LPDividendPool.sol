/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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

abstract contract AbsLPPool is Ownable {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 claimedReward;
    }

    struct PoolInfo {
        address lpToken;
        uint256 accPerShare;
        uint256 totalAmount;
        uint256 accReward;
        uint256 claimedReward;
    }

    struct Record {
        uint256 amount;
        uint256 start;
        uint256 end;
        uint256 status;
    }

    PoolInfo private poolInfo;
    mapping(address => UserInfo) private userInfo;
    //address -> records
    mapping(address => Record[]) private userRecords;

    address public fundAddress;
    mapping(address => bool) public _poolAdmin;
    uint256 public _lockDuration = 30 days;
    address public _rewardToken;

    constructor(address RewardToken, address FundAddress){
        _rewardToken = RewardToken;
        fundAddress = FundAddress;
    }

    function addTokenReward(uint256 reward) public {
        require(_poolAdmin[msg.sender], "not admin");
        if (reward > 0 && poolInfo.totalAmount > 0) {
            poolInfo.accPerShare += reward * 1e12 / poolInfo.totalAmount;
            poolInfo.accReward += reward;
        }
    }

    receive() external payable {}

    function deposit(uint256 amount) external {
        require(amount > 0, "=0");
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        _claim(user, account);

        IERC20(poolInfo.lpToken).transferFrom(msg.sender, address(this), amount);
        user.amount += amount;
        poolInfo.totalAmount += amount;

        user.rewardDebt = user.amount * poolInfo.accPerShare / 1e12;

        userRecords[account].push(
            Record(amount, block.timestamp, block.timestamp + _lockDuration, 0)
        );
    }

    function withdraw(uint256 index) public {
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        _claim(user, account);

        Record storage record = userRecords[account][index];

        require(0 == record.status, "had unlock");
        require(block.timestamp >= record.end, "not reach time");
        record.status = 1;

        uint256 amount = record.amount;

        IERC20(poolInfo.lpToken).transfer(msg.sender, amount);
        user.amount -= amount;
        poolInfo.totalAmount -= amount;

        user.rewardDebt = user.amount * poolInfo.accPerShare / 1e12;
    }

    function claim() public {
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        _claim(user, account);
    }

    function _claim(UserInfo storage user, address account) private {
        if (user.amount > 0) {
            uint256 accReward = user.amount * poolInfo.accPerShare / 1e12;
            uint256 pendingAmount = accReward - user.rewardDebt;
            if (pendingAmount > 0) {
                user.rewardDebt = accReward;
                user.claimedReward += pendingAmount;
                poolInfo.claimedReward += pendingAmount;
                IERC20(_rewardToken).transfer(account, pendingAmount);
            }
        }
    }

    function pendingReward(address account) private view returns (uint256 reward) {
        reward = 0;
        UserInfo storage user = userInfo[account];
        if (user.amount > 0) {
            reward = user.amount * poolInfo.accPerShare / 1e12 - user.rewardDebt;
        }
    }

    function getPoolView() public view returns (
        address lp, address rewardToken,
        uint256 amount, uint256 reward, uint256 claimedReward,
        uint256 lockDuration
    ) {
        lp = poolInfo.lpToken;
        rewardToken = _rewardToken;
        amount = poolInfo.totalAmount;
        reward = poolInfo.accReward;
        claimedReward = poolInfo.claimedReward;
        lockDuration = _lockDuration;
    }

    function getUserView(address account) public view returns (uint256 amount, uint256 pending, uint256 claimed, uint256 lpBalance) {
        UserInfo memory user = userInfo[account];
        amount = user.amount;
        pending = pendingReward(account);
        claimed = user.claimedReward;
        lpBalance = IERC20(poolInfo.lpToken).balanceOf(account);
    }

    function getPoolExtInfo() external view returns (
        uint256 rewardTokenDecimals,
        string memory rewardTokenSymbol,
        uint256 rewardBalance,
        uint256 lpTokenDecimals,
        string memory lpToken0Symbol,
        string memory lpToken1Symbol,
        uint256 blockTime
    ){
        rewardTokenDecimals = IERC20(_rewardToken).decimals();
        rewardTokenSymbol = IERC20(_rewardToken).symbol();
        rewardBalance = IERC20(_rewardToken).balanceOf(address(this));
        lpTokenDecimals = IERC20(poolInfo.lpToken).decimals();
        lpToken0Symbol = IERC20(ISwapPair(poolInfo.lpToken).token0()).symbol();
        lpToken1Symbol = IERC20(ISwapPair(poolInfo.lpToken).token1()).symbol();
        blockTime = block.timestamp;
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
        uint256[] memory amount,
        uint256[] memory startTime,
        uint256[] memory endTime,
        uint256[] memory status
    )
    {
        uint256 recordLen = userRecords[account].length;
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
            record = userRecords[account][i];
            amount[index] = record.amount;
            startTime[index] = record.start;
            endTime[index] = record.end;
            status[index] = record.status;
            index++;
        }
    }

    function setFundAddress(address addr) external onlyOwner {
        fundAddress = addr;
    }

    function setLPToken(address lpToken) external onlyOwner {
        require(poolInfo.totalAmount == 0, "started");
        poolInfo.lpToken = lpToken;
    }

    function setRewardToken(address rewardToken) external onlyOwner {
        _rewardToken = rewardToken;
    }

    function setPoolAdmin(address adr, bool enable) external onlyOwner {
        _poolAdmin[adr] = enable;
    }

    function setLockDuration(uint256 lockDuration) external onlyOwner {
        _lockDuration = lockDuration;
    }

    function claimBalance(uint256 amount) external {
        payable(fundAddress).transfer(amount);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        if (token == poolInfo.lpToken) {
            return;
        }
        IERC20(token).transfer(to, amount);
    }
}

contract LPDividendPool is AbsLPPool {
    constructor() AbsLPPool(
        address(0x55d398326f99059fF775485246999027B3197955),
        address(0x357341b67BeDb447603f01eb87a6296Ed8dffFc8)
    ){

    }
}