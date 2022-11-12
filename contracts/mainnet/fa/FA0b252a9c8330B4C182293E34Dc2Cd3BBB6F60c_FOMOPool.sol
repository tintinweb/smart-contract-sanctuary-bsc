/**
 *Submitted for verification at BscScan.com on 2022-11-12
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
        require(newOwner != address(0), "new 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IInviteToken {
    function bindInvitor(address account, address invitor) external;

    function _inviter(address account) external view returns (address);

    function getBinderLength(address account) external view returns (uint256);

    function _binders(address account, uint256 index) external view returns (address);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

abstract contract AbsPool is Ownable {
    struct PoolInfo {
        uint256 queueReward;
        uint256 poolReward;
        address[] accounts;
        uint256[] accountTimes;
        uint256 totalAmount;
        uint256 rewardTime;
        uint256 queueLen;
        uint256 queueRewardIndex;
        uint256 accPoolReward;
    }

    struct UserPoolInfo {
        uint256 amount;
    }

    struct UserInfo {
        uint256 totalUsdtReward;
        uint256 claimedUsdtReward;
        bool active;
    }

    uint256 public _poolId;
    mapping(uint256 => PoolInfo) private _poolInfo;
    //gameId => address => amount
    mapping(uint256 => mapping(address => UserPoolInfo)) private _userPoolInfo;

    uint256 public _totalJoinUsdt;
    uint256 public _totalClaimedUsdt;
    mapping(address => uint256) public _totalTokenAmount;

    mapping(address => UserInfo) private _userInfo;

    address private _usdtAddress;
    address private _tokenAddress;

    uint256 private _perUsdtAmount;
    uint256 private _perTokenAmount;
    uint256 public _refreshDuration = 86400;
    uint256 public _refreshAmount;

    uint256 public _queueRewardLen = 3;
    uint256 public _queueRewardRate = 5000;
    uint256 public _poolRewardRate = 2500;
    uint256 public _inviteRewardRate = 500;
    uint256 public _buybackRate = 1000;
    address public _fundAddress;
    uint256 public _lastRewardRate = 6000;
    uint256 public _lastRewardLen = 30;

    address[] public _userList;
    address public _tokenDestroyAddress = address(0x000000000000000000000000000000000000dEaD);

    uint256 public _buybackUsdt;
    address public _buybackTokenAddress;
    address public _buybackTokenDestroy = address(0x000000000000000000000000000000000000dEaD);

    address public _inviteTokenAddress;
    ISwapRouter public _swapRouter;

    constructor(address RouteAddress, address USDTAddress, address TokenAddress, address FundAddress){
        _swapRouter = ISwapRouter(RouteAddress);
        IERC20(USDTAddress).approve(RouteAddress, ~uint256(0));

        _usdtAddress = USDTAddress;
        _tokenAddress = TokenAddress;
        _fundAddress = FundAddress;
        uint256 usdtUnit = 10 ** IERC20(USDTAddress).decimals();
        _perUsdtAmount = 10 * usdtUnit;
        _refreshAmount = 100000 * usdtUnit;
        _perTokenAmount = 5 * 10 ** IERC20(TokenAddress).decimals();

        _buybackTokenAddress = TokenAddress;
        _inviteTokenAddress = TokenAddress;
    }

    function join() external {
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

        uint256 perTokenAmount = _perTokenAmount;
        address tokenAddress = _tokenAddress;
        _totalTokenAmount[tokenAddress] += perTokenAmount;
        _takeToken(tokenAddress, account, _tokenDestroyAddress, perTokenAmount);

        uint256 perUsdtAmount = _perUsdtAmount;
        _totalJoinUsdt += perUsdtAmount;
        _takeToken(_usdtAddress, account, address(this), perUsdtAmount);
        poolInfo.totalAmount += perUsdtAmount;
        uint256 queueReward = perUsdtAmount * _queueRewardRate / 10000;
        poolInfo.queueReward += queueReward;
        poolInfo.queueLen += 1;
        if (poolInfo.queueLen == _queueRewardLen) {
            poolInfo.queueLen = 0;
            address queueRewardAccount = poolInfo.accounts[poolInfo.queueRewardIndex];
            _userInfo[queueRewardAccount].totalUsdtReward += poolInfo.queueReward;
            poolInfo.queueReward = 0;
            poolInfo.queueRewardIndex += 1;
        }

        uint256 poolReward = perUsdtAmount * _poolRewardRate / 10000;
        poolInfo.poolReward += poolReward;

        uint256 inviteUsdt = perUsdtAmount * _inviteRewardRate / 10000;
        address invitor = IInviteToken(_inviteTokenAddress)._inviter(account);
        if (invitor == address(0)) {
            invitor = _fundAddress;
        }
        _totalClaimedUsdt += inviteUsdt;
        _giveToken(_usdtAddress, invitor, inviteUsdt);

        uint256 buybackUsdt = perUsdtAmount * _buybackRate / 10000;
        if (buybackUsdt > 0) {
            _buybackUsdt += buybackUsdt;
            address[] memory path = new address[](2);
            path[0] = _usdtAddress;
            path[1] = _buybackTokenAddress;
            _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                buybackUsdt, 0, path, _buybackTokenDestroy, block.timestamp
            );
        }

        uint256 fundUsdtAmount = perUsdtAmount - queueReward - poolReward - inviteUsdt - buybackUsdt;
        _totalClaimedUsdt += fundUsdtAmount;
        _giveToken(_usdtAddress, _fundAddress, fundUsdtAmount);

        _addUserAmount(poolId, account, perUsdtAmount);

        if (poolInfo.poolReward >= _refreshAmount) {
            _calReward(poolId);
            poolId += 1;
            _poolId = poolId;
        }
    }

    function _addUserAmount(uint256 poolId, address account, uint256 perUsdtAmount) private {
        UserPoolInfo storage userPoolInfo = _userPoolInfo[poolId][account];
        userPoolInfo.amount += perUsdtAmount;

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

    function _calReward(uint256 pid) private {
        PoolInfo storage poolInfo = _poolInfo[pid];
        if (poolInfo.accPoolReward > 0) {
            return;
        }
        uint256 poolReward = poolInfo.poolReward;

        uint256 lastReward = poolReward * _lastRewardRate / 10000;
        address[] storage accounts = poolInfo.accounts;
        uint256 accountLen = accounts.length;
        _userInfo[accounts[accountLen - 1]].totalUsdtReward += lastReward;

        uint256 lastTotalReward = poolReward - lastReward;
        uint256 lastRewardLen = _lastRewardLen;
        uint256 lastPerReward = lastTotalReward / (lastRewardLen - 0);

        uint256 start;
        if (accountLen > lastRewardLen) {
            start = accountLen - lastRewardLen;
        }
        uint256 end;
        if (accountLen > 0) {
            end = accountLen - 0;
        }
        for (uint256 i = start; i < end;) {
            _userInfo[accounts[i]].totalUsdtReward += lastPerReward;
            lastTotalReward -= lastPerReward;
        unchecked{
            ++i;
        }
        }
        if (lastTotalReward > 100) {
            _totalClaimedUsdt += lastTotalReward;
            _giveToken(_usdtAddress, _fundAddress, lastTotalReward);
        }
        poolInfo.accPoolReward = poolReward;
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

    function claimReward() external {
        calReward();
        address account = msg.sender;

        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingUsdt;
    unchecked{
        if (userInfo.totalUsdtReward > userInfo.claimedUsdtReward) {
            pendingUsdt = userInfo.totalUsdtReward - userInfo.claimedUsdtReward;
            userInfo.claimedUsdtReward += pendingUsdt;
        }
    }
        _giveToken(_usdtAddress, account, pendingUsdt);
        _totalClaimedUsdt += pendingUsdt;
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
        uint256 totalUsdtReward,
        uint256 claimedUsdtReward,
        uint256 usdtBalance,
        uint256 usdtAllowance,
        uint256 tokenBalance,
        uint256 tokenAllowance,
        bool isActive
    ){
        UserInfo storage userInfo = _userInfo[account];
        totalUsdtReward = getUserTotalUsdtReward(account);
        claimedUsdtReward = userInfo.claimedUsdtReward;
        usdtBalance = IERC20(_usdtAddress).balanceOf(account);
        usdtAllowance = IERC20(_usdtAddress).allowance(account, address(this));
        tokenBalance = IERC20(_tokenAddress).balanceOf(account);
        tokenAllowance = IERC20(_tokenAddress).allowance(account, address(this));
        isActive = userInfo.active;
    }

    function getUserTotalUsdtReward(address account) public view returns (uint256 totalUsdtReward){
        UserInfo storage userInfo = _userInfo[account];
        totalUsdtReward = userInfo.totalUsdtReward;
        totalUsdtReward += getUserLastUsdtReward(account);
    }

    function getUserLastUsdtReward(address account) public view returns (uint256 usdtReward){
        PoolInfo storage poolInfo = _poolInfo[_poolId];
        if (poolInfo.totalAmount == 0 || poolInfo.rewardTime > block.timestamp) {
            return usdtReward;
        }
        if (poolInfo.accPoolReward > 0) {
            return usdtReward;
        }

        uint256 poolReward = poolInfo.poolReward;

        uint256 lastReward = poolReward * _lastRewardRate / 10000;
        address[] storage accounts = poolInfo.accounts;
        uint256 accountLen = accounts.length;
        if (accounts[accountLen - 1] == account) {
            usdtReward += lastReward;
        }

        uint256 lastTotalReward = poolReward - lastReward;
        uint256 lastRewardLen = _lastRewardLen;
        uint256 lastPerReward = lastTotalReward / (lastRewardLen - 0);

        uint256 start;
        if (accountLen > lastRewardLen) {
            start = accountLen - lastRewardLen;
        }
        uint256 end;
        if (accountLen > 0) {
            end = accountLen - 0;
        }
        for (uint256 i = start; i < end;) {
            if (accounts[i] == account) {
                usdtReward += lastPerReward;
            }
        unchecked{
            ++i;
        }
        }
    }

    function getUserCurrentPoolInfo(address account) external view returns (uint256 amount){
        return getUserPoolInfo(getCurrentPoolId(), account);
    }

    function getUserPoolInfo(uint256 pid, address account) public view returns (uint256 amount){
        UserPoolInfo storage userPoolInfo = _userPoolInfo[pid][account];
        amount = userPoolInfo.amount;
    }

    function getTotalInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol,
        uint256 perUsdtAmount, uint256 perTokenAmount
    ){
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
        perUsdtAmount = _perUsdtAmount;
        perTokenAmount = _perTokenAmount;
    }

    function getExtInfo() external view returns (
        uint256 totalJoinUsdt, uint256 totalTokenAmount, uint256 totalAccountNum
    ){
        totalJoinUsdt = _totalJoinUsdt;
        totalTokenAmount = _totalTokenAmount[_tokenAddress];
        totalAccountNum = getUserListLength();
    }

    function getPoolInfo(uint256 pid) public view returns (
        uint256 poolReward, uint256 totalAmount, uint256 accPoolReward, uint256 rewardTime, uint256 accountLen
    ){
        PoolInfo storage poolInfo = _poolInfo[pid];
        poolReward = poolInfo.poolReward;
        totalAmount = poolInfo.totalAmount;
        accPoolReward = poolInfo.accPoolReward;
        rewardTime = poolInfo.rewardTime;
        accountLen = poolInfo.accounts.length;
    }

    function getCurrentPoolInfo() public view returns (
        uint256 poolReward, uint256 totalAmount, uint256 accPoolReward, uint256 rewardTime, uint256 accountLen, uint256 blockTime
    ){
        (poolReward, totalAmount, accPoolReward, rewardTime, accountLen) = getPoolInfo(getCurrentPoolId());
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
        uint256 queueReward, uint256 queueLen, uint256 queueRewardIndex
    ){
        PoolInfo storage poolInfo = _poolInfo[pid];
        queueReward = poolInfo.queueReward;
        queueLen = poolInfo.queueLen;
        queueRewardIndex = poolInfo.queueRewardIndex;
    }

    function setUsdtAddress(address adr) external onlyOwner {
        _usdtAddress = adr;
        IERC20(adr).approve(address(_swapRouter), ~uint256(0));
    }

    function setSwapRouter(address adr) external onlyOwner {
        _swapRouter = ISwapRouter(adr);
        IERC20(_usdtAddress).approve(adr, ~uint256(0));
    }

    function setTokenAddress(address adr) external onlyOwner {
        _tokenAddress = adr;
    }

    function setBuybackToken(address adr) external onlyOwner {
        _buybackTokenAddress = adr;
    }

    function setInviteToken(address adr) external onlyOwner {
        _inviteTokenAddress = adr;
    }

    function setFundAddress(address adr) external onlyOwner {
        _fundAddress = adr;
    }

    function setBuybackTokenDestroy(address adr) external onlyOwner {
        _buybackTokenDestroy = adr;
    }

    function setTokenDestroyAddress(address adr) external onlyOwner {
        _tokenDestroyAddress = adr;
    }

    function setPerUsdtAmount(uint256 perUsdtAmount) external onlyOwner {
        _perUsdtAmount = perUsdtAmount;
    }

    function setPerTokenAmount(uint256 perAmount) external onlyOwner {
        _perTokenAmount = perAmount;
    }

    function setRefreshDuration(uint256 refreshDuration) external onlyOwner {
        _refreshDuration = refreshDuration;
    }

    function setRefreshAmount(uint256 amount) external onlyOwner {
        _refreshAmount = amount;
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

    function setInviteRewardRate(uint256 inviteRewardRate) external onlyOwner {
        _inviteRewardRate = inviteRewardRate;
    }

    function setBuybackRate(uint256 buybackRate) external onlyOwner {
        _buybackRate = buybackRate;
    }

    function setLastRewardRate(uint256 lastRewardRate) external onlyOwner {
        _lastRewardRate = lastRewardRate;
    }

    function setLastRewardLen(uint256 lastRewardLen) external onlyOwner {
        _lastRewardLen = lastRewardLen;
    }
}

contract FOMOPool is AbsPool {
    constructor() AbsPool(
    //SwapRouter
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
    //usdt
        address(0x55d398326f99059fF775485246999027B3197955),
    //Token
        address(0x81881C1A3049FFd0dC8EeA547297cE389A1f8250),
    //fund
        address(0x2716Eb1B4b20f97AA731fe5ABEbc98BF6E49D67D)
    ){

    }
}