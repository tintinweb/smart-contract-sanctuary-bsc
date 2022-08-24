/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

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
    address internal _owner;

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

interface INFT {
    function transferFrom(address from, address to, uint256 tokenId) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

abstract contract AbsPool is Ownable {
    struct PoolInfo {
        uint256 ethQueueReward;
        uint256 ethPoolReward;
        address[] accounts;
        uint256[] accountTimes;
        uint256 totalAmount;
        uint256 rewardTime;
        uint256 accPoolReward;
        uint256 queueLen;
        uint256 queueRewardIndex;
    }

    struct UserPoolInfo {
        uint256 amount;
        uint256 status;
    }

    struct UserInfo {
        uint256[] poolIds;
        uint256 waitingCalIndex;
        uint256 totalEthReward;
        uint256 claimedEthReward;
        bool active;
    }

    uint256 public _poolId;
    mapping(uint256 => PoolInfo) private _poolInfo;
    mapping(uint256 => mapping(address => UserPoolInfo)) private _userPoolInfo;

    uint256 public _totalJoinEth;
    uint256 public _totalClaimedEth;
    uint256 public _totalNFTNum;

    mapping(address => UserInfo) private _userInfo;

    address private _ethAddress;

    address public _FOMONFTAddress;
    uint256 private _perEthAmount;
    uint256 public _refreshDuration = 86400;
    uint256 public _queueRewardLen = 3;
    uint256 public _queueRewardRate = 5000;
    uint256 public _poolRewardRate = 3000;
    address public _fundAddress;
    uint256 public _lastRewardRate = 5000;
    uint256 public _accRewardRate = 2000;
    uint256 public _lastRewardLen = 30;

    address[] public _userList;

    constructor(address ETHAddress, address FOMONFTAddress, address FundAddress){
        _ethAddress = ETHAddress;
        _FOMONFTAddress = FOMONFTAddress;
        _fundAddress = FundAddress;
        _perEthAmount = 10 ** (IERC20(ETHAddress).decimals() - 1);
    }

    function join(uint256 nftId) external {
        address account = msg.sender;
        uint256 poolId = _poolId;
        PoolInfo storage poolInfo = _poolInfo[poolId];
        uint256 blockTime = block.timestamp;
        if (poolInfo.totalAmount > 0 && poolInfo.rewardTime <= blockTime) {
            _calReward(poolId);
            poolId += 1;
            _poolId = poolId;
            poolInfo = _poolInfo[poolId];
        }
        poolInfo.rewardTime = blockTime + _refreshDuration;
        poolInfo.accounts.push(account);
        poolInfo.accountTimes.push(blockTime);

        _totalNFTNum += 1;
        INFT(_FOMONFTAddress).transferFrom(account, address(0x000000000000000000000000000000000000dEaD), nftId);

        uint256 perEthAmount = _perEthAmount;
        _totalJoinEth += perEthAmount;
        _takeToken(_ethAddress, account, address(this), perEthAmount);
        poolInfo.totalAmount += perEthAmount;
        uint256 ethQueueReward = perEthAmount * _queueRewardRate / 10000;
        poolInfo.ethQueueReward += ethQueueReward;
        poolInfo.queueLen += 1;
        if (poolInfo.queueLen == _queueRewardLen) {
            poolInfo.queueLen = 0;
            address queueRewardAccount = poolInfo.accounts[poolInfo.queueRewardIndex];
            _userInfo[queueRewardAccount].totalEthReward += poolInfo.ethQueueReward;
            poolInfo.ethQueueReward = 0;
            poolInfo.queueRewardIndex += 1;
        }

        uint256 ethPoolReward = perEthAmount * _poolRewardRate / 10000;
        poolInfo.ethPoolReward += ethPoolReward;
        uint256 fundEthAmount = perEthAmount - ethQueueReward - ethPoolReward;
        _totalClaimedEth += fundEthAmount;
        _giveToken(_ethAddress, _fundAddress, fundEthAmount);

        UserPoolInfo storage userPoolInfo = _userPoolInfo[poolId][account];
        userPoolInfo.amount += perEthAmount;
        _addUserPoolId(account, poolId);
        calUserPoolReward(account);

        if (!_userInfo[account].active) {
            _userInfo[account].active = true;
            _userList.push(account);
        }
    }

    function calReward() public {
        uint256 poolId = _poolId;
        PoolInfo storage poolInfo = _poolInfo[poolId];
        uint256 blockTime = block.timestamp;
        if (poolInfo.totalAmount > 0 && poolInfo.rewardTime <= blockTime) {
            _calReward(poolId);
            poolId += 1;
            _poolId = poolId;
        }
    }

    function _addUserPoolId(address account, uint256 poolId) private {
        UserInfo storage userInfo = _userInfo[account];
        uint256 poolIdLen = userInfo.poolIds.length;
        if (0 == poolIdLen || userInfo.poolIds[poolIdLen - 1] != poolId) {
            userInfo.poolIds.push(poolId);
        }
    }

    function _calReward(uint256 pid) private {
        PoolInfo storage poolInfo = _poolInfo[pid];
        if (poolInfo.accPoolReward > 0) {
            return;
        }
        uint256 ethPoolReward = poolInfo.ethPoolReward;

        uint256 accPoolReward = ethPoolReward * _accRewardRate / 10000;
        poolInfo.accPoolReward = accPoolReward;

        uint256 lastReward = ethPoolReward * _lastRewardRate / 10000;
        address[] storage accounts = poolInfo.accounts;
        uint256 accountLen = accounts.length;
        _userInfo[accounts[accountLen - 1]].totalEthReward += lastReward;

        uint256 lastTotalReward = ethPoolReward - lastReward - accPoolReward;
        uint256 lastRewardLen = _lastRewardLen;
        uint256 lastPerReward = lastTotalReward / (lastRewardLen - 1);

        uint256 start;
        if (accountLen > lastRewardLen) {
            start = accountLen - lastRewardLen;
        }
        uint256 end;
        if (accountLen > 1) {
            end = accountLen - 1;
        }
        for (uint256 i = start; i < end;) {
            _userInfo[accounts[i]].totalEthReward += lastPerReward;
            lastTotalReward -= lastPerReward;
        unchecked{
            ++i;
        }
        }
        if (lastTotalReward > 100) {
            _totalClaimedEth += lastTotalReward;
            _giveToken(_ethAddress, _fundAddress, lastTotalReward);
        }
    }

    function _takeToken(address tokenAddress, address account, address to, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(account) >= amount, "token not enough");
        token.transferFrom(account, to, amount);
    }

    function _giveToken(address tokenAddress, address account, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "pool token not enough");
        token.transfer(account, amount);
    }

    function calUserPoolReward(address account) public {
        UserInfo storage userInfo = _userInfo[account];
        uint256 index = userInfo.waitingCalIndex;
        uint256 len = userInfo.poolIds.length;
        PoolInfo storage poolInfo;
        UserPoolInfo storage userPoolInfo;
        uint256 poolId;
        for (; index < len;) {
            poolId = userInfo.poolIds[index];
            poolInfo = _poolInfo[poolId];
            if (poolInfo.accPoolReward == 0) {
                break;
            }
            userPoolInfo = _userPoolInfo[poolId][account];
            if (userPoolInfo.status == 1) {
                break;
            }
            userPoolInfo.status = 1;
            userInfo.totalEthReward += poolInfo.accPoolReward * userPoolInfo.amount / poolInfo.totalAmount;
        unchecked{
            index++;
        }
        }
        userInfo.waitingCalIndex = index;
    }

    function claimReward() external {
        calReward();
        address account = msg.sender;
        calUserPoolReward(account);

        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingEth;
    unchecked{
        if (userInfo.totalEthReward > userInfo.claimedEthReward) {
            pendingEth = userInfo.totalEthReward - userInfo.claimedEthReward;
            userInfo.claimedEthReward += pendingEth;
        }
    }
        _giveToken(_ethAddress, account, pendingEth);
        _totalClaimedEth += pendingEth;
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        address payable addr = payable(to);
        addr.transfer(amount);
    }

    function claimToken(address erc20Address, address to, uint256 amount) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(to, amount);
    }

    function getUserListLength() public view returns (uint256){
        return _userList.length;
    }

    function getUserInfo(address account) external view returns (
        uint256 waitingCalIndex,
        uint256 totalEthReward,
        uint256 claimedEthReward,
        uint256 ethBalance,
        uint256 ethAllowance,
        bool nftApproval
    ){
        UserInfo storage userInfo = _userInfo[account];
        waitingCalIndex = userInfo.waitingCalIndex;
        totalEthReward = getUserTotalEthReward(account);
        claimedEthReward = userInfo.claimedEthReward;
        ethBalance = IERC20(_ethAddress).balanceOf(account);
        ethAllowance = IERC20(_ethAddress).allowance(account, address(this));
        nftApproval = INFT(_FOMONFTAddress).isApprovedForAll(account, address(this));
    }

    function getUserTotalEthReward(address account) public view returns (uint256 totalEthReward){
        UserInfo storage userInfo = _userInfo[account];
        totalEthReward = userInfo.totalEthReward;
        totalEthReward += getUserLastEthReward(account);

        uint256 index = userInfo.waitingCalIndex;
        uint256 len = userInfo.poolIds.length;
        PoolInfo storage poolInfo;
        UserPoolInfo storage userPoolInfo;
        uint256 poolId;
        for (; index < len;) {
            poolId = userInfo.poolIds[index];
            poolInfo = _poolInfo[poolId];
            if (poolInfo.accPoolReward == 0) {
                break;
            }
            userPoolInfo = _userPoolInfo[poolId][account];
            if (userPoolInfo.status == 0) {
                totalEthReward += poolInfo.accPoolReward * userPoolInfo.amount / poolInfo.totalAmount;
            }
        unchecked{
            index++;
        }
        }
    }

    function getUserLastEthReward(address account) public view returns (uint256 ethReward){
        PoolInfo storage poolInfo = _poolInfo[_poolId];
        if (poolInfo.accPoolReward > 0 || poolInfo.totalAmount == 0 || poolInfo.rewardTime > block.timestamp) {
            return ethReward;
        }
        uint256 ethPoolReward = poolInfo.ethPoolReward;

        uint256 accPoolReward = ethPoolReward * _accRewardRate / 10000;

        uint256 lastReward = ethPoolReward * _lastRewardRate / 10000;
        address[] storage accounts = poolInfo.accounts;
        uint256 accountLen = accounts.length;
        if (accounts[accountLen - 1] == account) {
            ethReward += lastReward;
        }

        uint256 lastTotalReward = ethPoolReward - lastReward - accPoolReward;
        uint256 lastRewardLen = _lastRewardLen;
        uint256 lastPerReward = lastTotalReward / (lastRewardLen - 1);

        uint256 start;
        if (accountLen > lastRewardLen) {
            start = accountLen - lastRewardLen;
        }
        uint256 end;
        if (accountLen > 1) {
            end = accountLen - 1;
        }
        for (uint256 i = start; i < end;) {
            if (accounts[i] == account) {
                ethReward += lastPerReward;
            }
        unchecked{
            ++i;
        }
        }
        UserPoolInfo storage userPoolInfo = _userPoolInfo[_poolId][account];
        ethReward += accPoolReward * userPoolInfo.amount / poolInfo.totalAmount;
    }

    function getUserPoolIds(address account, uint256 start, uint256 length) external view returns (uint256 returnLen, uint256[] memory ids){
        UserInfo storage userInfo = _userInfo[account];
        uint256[] storage poolIds = userInfo.poolIds;
        uint256 idLength = poolIds.length;
        if (0 == length) {
            length = idLength;
        }
        returnLen = length;
        ids = new uint256[](length);

        uint256 index = 0;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= idLength)
                return (index, ids);
            ids[index] = poolIds[i];
            ++index;
        }
    }

    function getUserCurrentPoolInfo(address account) external view returns (uint256 amount, uint256 status){
        return getUserPoolInfo(getCurrentPoolId(), account);
    }

    function getUserPoolInfo(uint256 pid, address account) public view returns (uint256 amount, uint256 status){
        UserPoolInfo storage userPoolInfo = _userPoolInfo[pid][account];
        amount = userPoolInfo.amount;
        status = userPoolInfo.status;
    }

    function getTotalInfo() external view returns (
        address ethAddress, uint256 ethDecimals, string memory ethSymbol,
        uint256 totalJoinEth, uint256 totalNFTNum, uint256 totalAccountNum,
        uint256 perEthAmount
    ){
        ethAddress = _ethAddress;
        ethDecimals = IERC20(ethAddress).decimals();
        ethSymbol = IERC20(ethAddress).symbol();
        totalJoinEth = _totalJoinEth;
        totalNFTNum = _totalNFTNum;
        totalAccountNum = getUserListLength();
        perEthAmount = _perEthAmount;
    }

    function getPoolInfo(uint256 pid) public view returns (
        uint256 ethPoolReward, uint256 totalAmount, uint256 accPoolReward, uint256 rewardTime, uint256 accountLen
    ){
        PoolInfo storage poolInfo = _poolInfo[pid];
        ethPoolReward = poolInfo.ethPoolReward;
        totalAmount = poolInfo.totalAmount;
        accPoolReward = poolInfo.accPoolReward;
        rewardTime = poolInfo.rewardTime;
        accountLen = poolInfo.accounts.length;
    }

    function getCurrentPoolInfo() public view returns (
        uint256 ethPoolReward, uint256 totalAmount, uint256 accPoolReward, uint256 rewardTime, uint256 accountLen, uint256 blockTime
    ){
        (ethPoolReward, totalAmount, accPoolReward, rewardTime, accountLen) = getPoolInfo(getCurrentPoolId());
        blockTime = block.timestamp;
        if (rewardTime == 0) {
            rewardTime = blockTime + _refreshDuration;
        }
    }

    function getCurrentPoolId() public view returns (uint256 poolId){
        poolId = _poolId;
        PoolInfo storage poolInfo = _poolInfo[poolId];
        uint256 blockTime = block.timestamp;
        if (poolInfo.totalAmount > 0 && poolInfo.rewardTime <= blockTime) {
            poolId += 1;
        }
    }

    function getPoolAccounts(uint256 pid, uint256 start, uint256 length) external view returns (
        uint256 returnLen, address[] memory returnAccounts, uint256[] memory returnAccountTimes
    ){
        PoolInfo storage poolInfo = _poolInfo[pid];
        address[] storage accounts = poolInfo.accounts;
        uint256[] storage accountTimes = poolInfo.accountTimes;
        uint256 accountLength = accounts.length;
        if (0 == accountLength) {
            length = accountLength;
        }
        returnLen = length;
        returnAccounts = new address[](length);
        returnAccountTimes = new uint256[](length);

        uint256 index = 0;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= accountLength)
                return (index, returnAccounts, returnAccountTimes);
            returnAccounts[index] = accounts[i];
            returnAccountTimes[index] = accountTimes[i];
            ++index;
        }
    }


    function getPoolQueueInfo(uint256 pid) public view returns (
        uint256 ethQueueReward, uint256 queueLen, uint256 queueRewardIndex
    ){
        PoolInfo storage poolInfo = _poolInfo[pid];
        ethQueueReward = poolInfo.ethQueueReward;
        queueLen = poolInfo.queueLen;
        queueRewardIndex = poolInfo.queueRewardIndex;
    }

    function setEthAddress(address adr) external onlyOwner {
        _ethAddress = adr;
    }

    function setFOMONFTAddress(address adr) external onlyOwner {
        _FOMONFTAddress = adr;
    }

    function setFundAddress(address adr) external onlyOwner {
        _fundAddress = adr;
    }

    function setPerEthAmount(uint256 perEthAmount) external onlyOwner {
        _perEthAmount = perEthAmount;
    }

    function setRefreshDuration(uint256 refreshDuration) external onlyOwner {
        _refreshDuration = refreshDuration;
    }

    function setQueueRewardLen(uint256 queueRewardLen) external onlyOwner {
        _queueRewardLen = queueRewardLen;
    }

    function setQueueRewardRate(uint256 queueRewardRate) external onlyOwner {
        _queueRewardRate = queueRewardRate;
    }

    function setPoolRewardRate(uint256 poolRewardRate) external onlyOwner {
        _poolRewardRate = poolRewardRate;
    }

    function setLastRewardRate(uint256 lastRewardRate) external onlyOwner {
        _lastRewardRate = lastRewardRate;
    }

    function setAccRewardRate(uint256 accRewardRate) external onlyOwner {
        _accRewardRate = accRewardRate;
    }

    function setLastRewardLen(uint256 lastRewardLen) external onlyOwner {
        _lastRewardLen = lastRewardLen;
    }
}

contract FOMOPool is AbsPool {
    constructor() AbsPool(
        address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8),
        address(0x3E0bbD3932CA8fE530e3B661B039E1c4bc9716AA),
        address(0x96Bcc1e121D293102c832aED3A2fe69c75194EC0)
    ){

    }
}