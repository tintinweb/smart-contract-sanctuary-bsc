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

interface ISwapRouter {
    function factory() external pure returns (address);
}

interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

abstract contract AbsPool is Ownable {
    struct PoolInfo {
        uint256 ethReward;
        uint256 usdtQty;
        uint256 usdtAmount;
        uint256 accountNum;
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
        uint256 userTotalUsdt;
    }

    uint256 public _poolId;
    mapping(uint256 => PoolInfo) private _poolInfo;
    mapping(uint256 => mapping(address => UserPoolInfo)) private _userPoolInfo;

    uint256 public _totalRewardEth;
    uint256 public _totalClaimedEth;

    mapping(address => UserInfo) private _userInfo;
    mapping(address => bool) public _admin;

    address private _USDTAddress;
    address private _ethAddress;

    ISwapFactory public _factory;

    constructor(address RouteAddress, address USDTAddress, address ETHAddress){
        ISwapRouter swapRouter = ISwapRouter(RouteAddress);
        _factory = ISwapFactory(swapRouter.factory());
        _USDTAddress = USDTAddress;
        _ethAddress = ETHAddress;
    }

    function addAmount(address account, uint256 amount) external {
        address caller = msg.sender;
        require(_admin[caller], "not Admin");
        if (0 == amount) {
            return;
        }
        uint256 poolId = _poolId;
        PoolInfo storage poolInfo = _poolInfo[poolId];
        require(poolInfo.usdtQty > 0, "no Qty");

        uint256 remainAmount = poolInfo.usdtQty - poolInfo.usdtAmount;
        if (remainAmount > amount) {
            poolInfo.usdtAmount += amount;

            UserPoolInfo storage userPoolInfo = _userPoolInfo[poolId][account];
            if (0 == userPoolInfo.amount) {
                poolInfo.accountNum += 1;
            }
            userPoolInfo.amount += amount;
            _addUserGameId(account, poolId);
        } else {
            poolInfo.usdtAmount += remainAmount;

            UserPoolInfo storage userPoolInfo = _userPoolInfo[poolId][account];
            if (0 == userPoolInfo.amount) {
                poolInfo.accountNum += 1;
            }
            userPoolInfo.amount += remainAmount;
            _addUserGameId(account, poolId);

            uint256 nextId = poolId + 1;
            PoolInfo storage nextPool = _poolInfo[nextId];
            nextPool.ethReward = poolInfo.ethReward;
            nextPool.usdtQty = tokenUValue(_ethAddress, poolInfo.ethReward);
            uint256 moreAmount = amount - remainAmount;
            if (moreAmount > 0) {
                nextPool.accountNum += 1;
            }
            _totalRewardEth += poolInfo.ethReward;
            require(nextPool.usdtQty > moreAmount, "qty not enough");
            nextPool.usdtAmount += moreAmount;
            _poolId = nextId;

            UserPoolInfo storage userNextPool = _userPoolInfo[nextId][account];
            userNextPool.amount += moreAmount;
            _addUserGameId(account, nextId);
        }

        _userInfo[account].userTotalUsdt += amount;
        calUserPoolReward(account);
    }

    function _addUserGameId(address account, uint256 poolId) private {
        UserInfo storage userInfo = _userInfo[account];
        uint256 poolIdLen = userInfo.poolIds.length;
        if (0 == poolIdLen || userInfo.poolIds[poolIdLen - 1] != poolId) {
            userInfo.poolIds.push(poolId);
        }
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
            if (poolInfo.usdtQty > poolInfo.usdtAmount || poolInfo.usdtQty == 0) {
                break;
            }
            userPoolInfo = _userPoolInfo[poolId][account];
            if (userPoolInfo.status == 1) {
                break;
            }
            userPoolInfo.status = 1;
            userInfo.totalEthReward = userInfo.totalEthReward + poolInfo.ethReward * userPoolInfo.amount / poolInfo.usdtAmount;
        unchecked{
            ++index;
        }
        }
        userInfo.waitingCalIndex = index;
    }

    function claimReward() external {
        address account = msg.sender;
        calUserPoolReward(account);

        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingEth = userInfo.totalEthReward - userInfo.claimedEthReward;
        userInfo.claimedEthReward += pendingEth;
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

    function tokenUValue(address tokenAddress, uint256 tokenAmount) public view returns (uint256){
        address usdtAddress = _USDTAddress;
        address lpAddress = _factory.getPair(usdtAddress, tokenAddress);
        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(lpAddress);
        uint256 usdtBalance = IERC20(usdtAddress).balanceOf(lpAddress);
        return tokenAmount * usdtBalance / tokenBalance;
    }

    function getPoolInfo(uint256 poolId) public view returns (
        uint256 ethReward,
        uint256 usdtQty,
        uint256 usdtAmount,
        uint256 ethUValue,
        uint256 accountNum
    ){
        PoolInfo storage poolInfo = _poolInfo[poolId];
        ethReward = poolInfo.ethReward;
        usdtQty = poolInfo.usdtQty;
        usdtAmount = poolInfo.usdtAmount;
        ethUValue = tokenUValue(_ethAddress, ethReward);
        accountNum = poolInfo.accountNum;
    }

    function getCurrentPoolInfo() public view returns (
        uint256 ethReward,
        uint256 usdtQty,
        uint256 usdtAmount,
        uint256 ethUValue,
        uint256 accountNum
    ){
        return getPoolInfo(_poolId);
    }

    function getUserInfo(address account) external view returns (
        uint256 waitingCalIndex,
        uint256 totalEthReward,
        uint256 claimedEthReward,
        uint256 userTotalUsdt
    ){
        UserInfo storage userInfo = _userInfo[account];
        waitingCalIndex = userInfo.waitingCalIndex;
        totalEthReward = getUserTotalEthReward(account);
        claimedEthReward = userInfo.claimedEthReward;
        userTotalUsdt = userInfo.userTotalUsdt;
    }

    function getUserTotalEthReward(address account) public view returns (uint256 totalEthReward){
        UserInfo storage userInfo = _userInfo[account];
        totalEthReward = userInfo.totalEthReward;
        uint256 index = userInfo.waitingCalIndex;
        uint256 len = userInfo.poolIds.length;
        PoolInfo storage poolInfo;
        UserPoolInfo storage userPoolInfo;
        uint256 poolId;
        for (; index < len;) {
            poolId = userInfo.poolIds[index];
            poolInfo = _poolInfo[poolId];
            if (poolInfo.usdtQty > poolInfo.usdtAmount || poolInfo.usdtQty == 0) {
                break;
            }
            userPoolInfo = _userPoolInfo[poolId][account];
            if (userPoolInfo.status == 0) {
                totalEthReward += poolInfo.ethReward * userPoolInfo.amount / poolInfo.usdtAmount;
            }
        unchecked{
            index++;
        }
        }
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

    function getUserPoolInfo(uint256 pid, address account) public view returns (uint256 amount, uint256 status, uint256 rewardEth){
        UserPoolInfo storage userPoolInfo = _userPoolInfo[pid][account];
        amount = userPoolInfo.amount;
        status = userPoolInfo.status;
        PoolInfo storage poolInfo = _poolInfo[pid];
        if (poolInfo.usdtQty > 0) {
            rewardEth = poolInfo.ethReward * amount / poolInfo.usdtQty;
        }
    }

    function getUserCurrentPoolInfo(address account) external view returns (uint256 amount, uint256 status, uint256 rewardEth){
        return getUserPoolInfo(_poolId, account);
    }

    function tokenInfo() external view returns (
        address USDTAddress, uint256 USDTDecimals, string memory USDTSymbol,
        address ethAddress, uint256 ethDecimals, string memory ethSymbol, uint256 ethPrice
    ){
        USDTAddress = _USDTAddress;
        USDTDecimals = IERC20(USDTAddress).decimals();
        USDTSymbol = IERC20(USDTAddress).symbol();
        ethAddress = _ethAddress;
        ethDecimals = IERC20(ethAddress).decimals();
        ethSymbol = IERC20(ethAddress).symbol();
        ethPrice = tokenUValue(ethAddress, 10 ** IERC20(ethAddress).decimals());
    }

    function setUSDTAddress(address adr) external onlyOwner {
        _USDTAddress = adr;
    }

    function setEthAddress(address adr) external onlyOwner {
        _ethAddress = adr;
    }

    function setPoolEthReward(uint256 ethAmount) public onlyOwner {
        PoolInfo storage poolInfo = _poolInfo[_poolId];
        _totalRewardEth -= poolInfo.ethReward;
        poolInfo.ethReward = ethAmount;
        uint256 uValue = tokenUValue(_ethAddress, poolInfo.ethReward);
        require(uValue >= poolInfo.usdtAmount, "lt usdtAmount");
        poolInfo.usdtQty = uValue;
        _totalRewardEth += ethAmount;
    }

    function setAdmin(address addr, bool enable) external onlyOwner {
        _admin[addr] = enable;
    }
}

contract ResonancePool is AbsPool {
    constructor() AbsPool(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        address(0x2170Ed0880ac9A755fd29B2688956BD959F933F8)
    ){

    }
}