/**
 *Submitted for verification at BscScan.com on 2022-09-19
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

interface ISwapRouter {
    function factory() external pure returns (address);
}

interface ISwapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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

contract BCakeMintPool is Ownable {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        bool active;
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
        uint256 totalReward;
    }

    PoolInfo[] private _poolInfos;
    mapping(uint256 => mapping(address => UserInfo)) private _userInfos;
    mapping(address => uint256) public _poolLpBalances;
    mapping(address => bool) public _singleToken;

    uint256 public constant _rewardFactor = 1e12;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;
    uint256 public constant _feeDivFactor = 10000;
    uint256 public _inviteFee = 300;

    mapping(address => bool) private _userActive;

    ISwapRouter public _swapRouter;
    ISwapFactory public _factory;
    address private _usdtAddress;

    function poolLength() public view returns (uint256) {
        return _poolInfos.length;
    }

    function bindInvitor(address invitor) external {
        address account = msg.sender;
        require(invitor != account, "self");
        require(address(0) != invitor, "invitor 0");
        require(address(0) == _invitor[account], "Bind");
        require(!_userActive[account], "active");
        require(_binder[account].length == 0, "had binders");
        _invitor[account] = invitor;
        _binder[invitor].push(account);
    }

    function deposit(uint256 pid, uint256 amount) external {
        require(amount > 0, "deposit == 0");
        address account = msg.sender;
        if (!_userActive[account]) {
            _userActive[account] = true;
        }

        _updatePool(pid);

        UserInfo storage user = _userInfos[pid][account];
        _claim(pid, user, account);

        PoolInfo storage pool = _poolInfos[pid];

        IERC20 lpToken = IERC20(pool.lpToken);
        uint256 beforeAmount = lpToken.balanceOf(address(this));
        lpToken.transferFrom(account, address(this), amount);
        uint256 afterAmount = lpToken.balanceOf(address(this));
        amount = afterAmount - beforeAmount;

        user.amount += amount;
        pool.totalAmount += amount;
        _poolLpBalances[pool.lpToken] += amount;
        user.rewardDebt = user.amount * pool.accPerShare / _rewardFactor;
    }

    function withdraw(uint256 pid, uint256 amount) public {
        _updatePool(pid);

        address account = msg.sender;
        UserInfo storage user = _userInfos[pid][account];
        if (amount > user.amount) {
            amount = user.amount;
        }
        _claim(pid, user, account);
        PoolInfo storage pool = _poolInfos[pid];
        if (amount > 0) {
            IERC20(pool.lpToken).transfer(account, amount);
            user.amount -= amount;
            pool.totalAmount -= amount;
            _poolLpBalances[pool.lpToken] -= amount;
        }
        user.rewardDebt = user.amount * pool.accPerShare / _rewardFactor;
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
        uint256 timePerBlock,
        uint256 totalReward
    ) external onlyOwner {
        uint256 blockTimestamp = block.timestamp;
        uint256 blockNum = block.number;
        uint256 startBlock;
        if (startTime > blockTimestamp) {
            startBlock = blockNum + (startTime - blockTimestamp) / timePerBlock;
        } else {
            startBlock = blockNum;
        }
        _poolInfos.push(PoolInfo({
        lpToken : lpToken,
        rewardToken : rewardToken,
        rewardPerBlock : rewardPerBlock,
        lastRewardBlock : startBlock,
        accPerShare : 0,
        totalAmount : 0,
        accReward : 0,
        startTime : startTime,
        endTime : endTime,
        totalReward : totalReward
        }));
    }

    function setPoolRewardPerBlock(uint256 pid, uint256 rewardPerBlock) external onlyOwner {
        _updatePool(pid);
        _poolInfos[pid].rewardPerBlock = rewardPerBlock;
    }

    function setPoolTotalReward(uint256 pid, uint256 totalReward) external onlyOwner {
        _updatePool(pid);
        _poolInfos[pid].totalReward = totalReward;
    }

    function setPoolLP(uint256 pid, address lp) external onlyOwner {
        PoolInfo storage pool = _poolInfos[pid];
        require(pool.totalAmount == 0, "started");
        pool.lpToken = lp;
    }

    function setPoolRewardToken(uint256 pid, address token) external onlyOwner {
        PoolInfo storage pool = _poolInfos[pid];
        pool.rewardToken = token;
    }

    function setPoolTime(uint256 pid, uint256 startTime, uint256 endTime, uint256 timePerBlock) external onlyOwner {
        PoolInfo storage pool = _poolInfos[pid];
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
        PoolInfo storage pool = _poolInfos[pid];
        require(pool.lastRewardBlock > blockNum && pool.accReward == 0, "started");
        pool.lastRewardBlock = blockNum;
    }

    receive() external payable {

    }

    function _updatePool(uint256 pid) private {
        PoolInfo storage pool = _poolInfos[pid];
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
            pool.accPerShare += reward * _rewardFactor / totalAmount;
            pool.accReward += reward;
        }
    }

    function _claim(uint256 pid, UserInfo storage user, address account) private {
        PoolInfo storage pool = _poolInfos[pid];
        uint256 userAmount = user.amount;
        if (userAmount > 0) {
            uint256 pendingAmount = userAmount * pool.accPerShare / _rewardFactor - user.rewardDebt;
            if (pendingAmount > 0) {
                user.rewardDebt = userAmount * pool.accPerShare / _rewardFactor;
                IERC20 rewardToken = IERC20(pool.rewardToken);
                require(rewardToken.balanceOf(address(this)) >= pendingAmount, "rewardToken not enough");
                address invitor = _invitor[account];
                if (address(0) != invitor) {
                    uint256 inviteAmount = pendingAmount * _inviteFee / _feeDivFactor;
                    if (inviteAmount > 0) {
                        pendingAmount -= inviteAmount;
                        rewardToken.transfer(invitor, inviteAmount);
                    }
                }
                rewardToken.transfer(account, pendingAmount);
            }
        }
    }

    function _pendingReward(uint256 pid, address account) private view returns (uint256 reward) {
        reward = 0;
        PoolInfo storage pool = _poolInfos[pid];
        UserInfo storage user = _userInfos[pid][account];
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
            reward = user.amount * (pool.accPerShare + poolPendingReward * _rewardFactor / pool.totalAmount) / _rewardFactor - user.rewardDebt;
        }
    }

    function getPoolInfo(uint256 pid) public view returns (
        address lpToken, address rewardToken,
        uint256 rewardPerBlock, uint256 amount,
        uint256 lpPrice, uint256 rewardTokenPrice
    ) {
        PoolInfo storage pool = _poolInfos[pid];
        lpToken = pool.lpToken;
        rewardToken = pool.rewardToken;
        rewardPerBlock = pool.rewardPerBlock;
        amount = pool.totalAmount;

        if (_singleToken[lpToken]) {
            lpPrice = getTokenPrice(lpToken);
        } else {
            ISwapPair swapPair = ISwapPair(lpToken);
            address token = swapPair.token0();
            uint256 tokenPrice = getTokenPrice(token);
            if (0 == tokenPrice) {
                token = swapPair.token1();
                tokenPrice = getTokenPrice(token);
            }
            uint256 uValue = IERC20(token).balanceOf(lpToken) * tokenPrice / (10 ** IERC20(token).decimals());
            lpPrice = 10 ** IERC20(lpToken).decimals() * uValue * 2 / IERC20(lpToken).totalSupply();
        }

        rewardTokenPrice = getTokenPrice(rewardToken);
    }

    function getPoolData(uint256 pid) public view returns (
        uint256 reward, uint256 totalReward,
        uint256 startTime, uint256 endTime
    ) {
        PoolInfo storage pool = _poolInfos[pid];
        reward = pool.accReward;
        totalReward = pool.totalReward;
        startTime = pool.startTime;
        endTime = pool.endTime;
    }

    function getTokenPrice(address token) public view returns (uint256 price){
        address usdtPair = _factory.getPair(token, _usdtAddress);
        uint256 usdtAmount = IERC20(_usdtAddress).balanceOf(usdtPair);
        uint256 tokenAmount = IERC20(token).balanceOf(usdtPair);
        if (tokenAmount > 0) {
            price = 10 ** IERC20(token).decimals() * usdtAmount / tokenAmount;
        }
    }

    function getPoolExtInfo(uint256 pid) public view returns (
        uint256 rewardTokenDecimals, string memory rewardTokenSymbol,
        uint256 lpTokenDecimals, string memory lpToken0Symbol, string memory lpToken1Symbol
    ) {
        PoolInfo storage pool = _poolInfos[pid];

        rewardTokenDecimals = IERC20(pool.rewardToken).decimals();
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

    function getBaseInfo() public view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        uint256 timestamp, uint256 blockNum
    ) {
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        timestamp = block.timestamp;
        blockNum = block.number;
    }

    function getUserInfo(uint256 pid, address account) public view returns (
        uint256 amount, uint256 pending, uint256 lpBalance, uint256 lpAllowance, bool active
    ) {
        UserInfo storage user = _userInfos[pid][account];
        amount = user.amount;
        pending = _pendingReward(pid, account);
        lpBalance = IERC20(_poolInfos[pid].lpToken).balanceOf(account);
        lpAllowance = IERC20(_poolInfos[pid].lpToken).allowance(account, address(this));
        active = _userActive[account];
    }

    function getBinderLength(address account) public view returns (uint256){
        return _binder[account].length;
    }

    function emergencyWithdraw(uint256 pid) external {
        _updatePool(pid);
        PoolInfo storage pool = _poolInfos[pid];
        address account = msg.sender;
        UserInfo storage user = _userInfos[pid][account];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        IERC20(pool.lpToken).transfer(account, amount);
        pool.totalAmount -= amount;
        _poolLpBalances[pool.lpToken] -= amount;
    }

    function setSingleToken(address token, bool enable) external onlyOwner {
        _singleToken[token] = enable;
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(address token, address to, uint256 amount) external onlyOwner {
        uint256 maxClaim = IERC20(token).balanceOf(address(this)) - _poolLpBalances[token];
        if (amount > maxClaim) {
            amount = maxClaim;
        }
        IERC20(token).transfer(to, amount);
    }

    function setInviteFee(uint256 fee) external onlyOwner {
        _inviteFee = fee;
    }

    function setUsdtAddress(address usdt) external onlyOwner {
        _usdtAddress = usdt;
    }

    function setSwapRouter(address swapRouterAddress) external onlyOwner {
        ISwapRouter swapRouter = ISwapRouter(swapRouterAddress);
        _factory = ISwapFactory(swapRouter.factory());
        _swapRouter = swapRouter;
    }

    constructor(){
        ISwapRouter swapRouter = ISwapRouter(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));
        _factory = ISwapFactory(swapRouter.factory());
        _swapRouter = swapRouter;
        _usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
    }
}