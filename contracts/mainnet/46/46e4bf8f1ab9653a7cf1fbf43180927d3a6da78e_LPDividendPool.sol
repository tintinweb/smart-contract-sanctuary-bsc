/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

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
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IRewardToken {
    function minusLPAmount(address account, uint256 amount) external;

    function addLPAmount(address account, uint256 amount) external;

    function _limitAmount() external view returns (uint256);

    function _feeWhiteList(address account) external view returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

abstract contract AbsLPPool is Ownable {
    struct UserInfo {
        bool isActive;
        uint256 amount;
        uint256 rewardTokenDebt;
        uint256 calTokenReward;

        uint256 rewardLPDebt;
        uint256 calLPReward;

        uint256 rewardMintDebt;
        uint256 calMintReward;
    }

    struct PoolInfo {
        uint256 totalAmount;
        uint256 accTokenPerShare;
        uint256 accTokenReward;

        uint256 accLPPerShare;
        uint256 accLPReward;

        uint256 accMintPerShare;
        uint256 accMintReward;
        uint256 mintPerBlock;
        uint256 lastMintBlock;
        uint256 totalMintReward;
    }

    PoolInfo private poolInfo;
    mapping(address => UserInfo) private userInfo;

    address private _lpToken;
    string private _lpTokenSymbol;
    address private _rewardToken;
    address private _mintRewardToken;

    mapping(address => address) public _invitor;
    mapping(address => address[]) public _binder;
    uint256 public _inviteFee = 1000;

    constructor(
        address LPToken, string memory LPTokenSymbol,
        address RewardToken,  address MintRewardToken
    ){
        _lpToken = LPToken;
        _lpTokenSymbol = LPTokenSymbol;
        _rewardToken = RewardToken;
        _mintRewardToken = MintRewardToken;
        poolInfo.lastMintBlock = block.number;
    }

    function addTokenReward(uint256 reward) public {
        require(msg.sender == _rewardToken, "rq Token");
        if (reward > 0 && poolInfo.totalAmount > 0) {
            poolInfo.accTokenPerShare += reward * 1e18 / poolInfo.totalAmount;
            poolInfo.accTokenReward += reward;
        }
    }

    function addLPTokenReward(uint256 reward) public {
        require(msg.sender == _rewardToken, "rq Token");
        if (reward > 0 && poolInfo.totalAmount > 0) {
            poolInfo.accLPPerShare += reward * 1e18 / poolInfo.totalAmount;
            poolInfo.accLPReward += reward;
        }
    }

    receive() external payable {}

    function deposit(uint256 amount, address invitor) external {
        require(amount > 0, "=0");
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        if (!user.isActive) {
            user.isActive = true;
            if (userInfo[invitor].isActive) {
                _invitor[account] = invitor;
                _binder[invitor].push(account);
            }
        }
        _calReward(user);

        IERC20(_lpToken).transferFrom(msg.sender, address(this), amount);

        user.amount += amount;
        poolInfo.totalAmount += amount;
        IRewardToken(_rewardToken).minusLPAmount(account, amount);

        user.rewardTokenDebt = user.amount * poolInfo.accTokenPerShare / 1e18;
        user.rewardLPDebt = user.amount * poolInfo.accLPPerShare / 1e18;
        user.rewardMintDebt = user.amount * poolInfo.accMintPerShare / 1e18;
    }

    function withdraw() public {
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        _calReward(user);

        uint256 amount = user.amount;

        IERC20(_lpToken).transfer(msg.sender, amount);

        user.amount -= amount;
        poolInfo.totalAmount -= amount;
        IRewardToken(_rewardToken).addLPAmount(account, amount);

        user.rewardTokenDebt = user.amount * poolInfo.accTokenPerShare / 1e18;
        user.rewardLPDebt = user.amount * poolInfo.accLPPerShare / 1e18;
        user.rewardMintDebt = user.amount * poolInfo.accMintPerShare / 1e18;
    }

    function claim() public {
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        _calReward(user);
        uint256 pendingToken = user.calTokenReward;
        if (pendingToken > 0) {
            IRewardToken rewardToken = IRewardToken(_rewardToken);
            uint256 limitAmount = rewardToken._limitAmount();
            if (!rewardToken._feeWhiteList(account) && limitAmount > 0 && rewardToken.balanceOf(account) + pendingToken > limitAmount) {
                pendingToken = 0;
            }
            if (pendingToken > 0) {
                rewardToken.transfer(account, pendingToken);
                user.calTokenReward = 0;
            }
        }
        uint256 pendingLP = user.calLPReward;
        if (pendingLP > 0) {
            IERC20(_lpToken).transfer(account, pendingLP);
            user.calLPReward = 0;
            IRewardToken(_rewardToken).addLPAmount(account,pendingLP);
        }
        uint256 pendingMint = user.calMintReward;
        if (pendingMint > 0) {
            IERC20 mintRewardToken = IERC20(_mintRewardToken);
            address invitor = _invitor[account];
            if (address(0) != invitor) {
                uint256 inviteAmount = pendingMint * _inviteFee / 10000;
                if (inviteAmount > 0) {
                    pendingMint -= inviteAmount;
                    mintRewardToken.transfer(invitor, inviteAmount);
                }
            }
            mintRewardToken.transfer(account, pendingMint);
            user.calMintReward = 0;
        }
    }

    function _updatePool() private {
        PoolInfo storage pool = poolInfo;
        uint256 blockNum = block.number;
        uint256 lastRewardBlock = pool.lastMintBlock;
        if (blockNum <= lastRewardBlock) {
            return;
        }
        pool.lastMintBlock = blockNum;

        uint256 accReward = pool.accMintReward;
        uint256 totalReward = pool.totalMintReward;
        if (accReward >= totalReward) {
            return;
        }

        uint256 totalAmount = pool.totalAmount;
        uint256 rewardPerBlock = pool.mintPerBlock;
        if (0 < totalAmount && 0 < rewardPerBlock) {
            uint256 reward = rewardPerBlock * (blockNum - lastRewardBlock);
            uint256 remainReward = totalReward - accReward;
            if (reward > remainReward) {
                reward = remainReward;
            }
            pool.accMintPerShare += reward * 1e18 / totalAmount;
            pool.accMintReward += reward;
        }
    }

    function _calReward(UserInfo storage user) private {
        _updatePool();
        if (user.amount > 0) {
            uint256 accMintReward = user.amount * poolInfo.accMintPerShare / 1e18;
            uint256 pendingMintAmount = accMintReward - user.rewardMintDebt;
            if (pendingMintAmount > 0) {
                user.rewardMintDebt = accMintReward;
                user.calMintReward += pendingMintAmount;
            }

            uint256 accLPReward = user.amount * poolInfo.accLPPerShare / 1e18;
            uint256 pendingLPAmount = accLPReward - user.rewardLPDebt;
            if (pendingLPAmount > 0) {
                user.rewardLPDebt = accLPReward;
                user.calLPReward += pendingLPAmount;
            }

            uint256 accTokenReward = user.amount * poolInfo.accTokenPerShare / 1e18;
            uint256 pendingAmount = accTokenReward - user.rewardTokenDebt;
            if (pendingAmount > 0) {
                user.rewardTokenDebt = accTokenReward;
                user.calTokenReward += pendingAmount;
            }
        }
    }

    function pendingTokenReward(address account) private view returns (uint256 reward) {
        reward = 0;
        UserInfo storage user = userInfo[account];
        if (user.amount > 0) {
            reward = user.amount * poolInfo.accTokenPerShare / 1e18 - user.rewardTokenDebt;
        }
    }

    function pendingLPReward(address account) private view returns (uint256 reward) {
        reward = 0;
        UserInfo storage user = userInfo[account];
        if (user.amount > 0) {
            reward = user.amount * poolInfo.accLPPerShare / 1e18 - user.rewardLPDebt;
        }
    }

    function _calPendingMintReward(address account) private view returns (uint256 reward) {
        reward = 0;
        PoolInfo storage pool = poolInfo;
        UserInfo storage user = userInfo[account];
        if (user.amount > 0) {
            uint256 poolPendingReward;
            uint256 blockNum = block.number;
            uint256 lastRewardBlock = pool.lastMintBlock;
            if (blockNum > lastRewardBlock) {
                poolPendingReward = pool.mintPerBlock * (blockNum - lastRewardBlock);
                uint256 totalReward = pool.totalMintReward;
                uint256 accReward = pool.accMintReward;
                uint256 remainReward;
                if (totalReward > accReward) {
                    remainReward = totalReward - accReward;
                }
                if (poolPendingReward > remainReward) {
                    poolPendingReward = remainReward;
                }
            }
            reward = user.amount * (pool.accMintPerShare + poolPendingReward * 1e18 / pool.totalAmount) / 1e18 - user.rewardMintDebt;
        }
    }

    function getPoolInfo() public view returns (
        uint256 totalAmount,
        uint256 accTokenPerShare, uint256 accTokenReward,
        uint256 accLPPerShare, uint256 accLPReward,
        uint256 accMintPerShare, uint256 accMintReward,
        uint256 mintPerBlock, uint256 lastMintBlock, uint256 totalMintReward
    ) {
        totalAmount = poolInfo.totalAmount;
        accTokenPerShare = poolInfo.accTokenPerShare;
        accTokenReward = poolInfo.accTokenReward;
        accLPPerShare = poolInfo.accLPPerShare;
        accLPReward = poolInfo.accLPReward;
        accMintPerShare = poolInfo.accMintPerShare;
        accMintReward = poolInfo.accMintReward;
        mintPerBlock = poolInfo.mintPerBlock;
        lastMintBlock = poolInfo.lastMintBlock;
        totalMintReward = poolInfo.totalMintReward;
    }

    function getUserInfo(address account) public view returns (
        uint256 amount, uint256 lpAllowance,
        uint256 pendingToken, uint256 pendingLP, uint256 pendingMintReward
    ) {
        UserInfo storage user = userInfo[account];
        amount = user.amount;
        lpAllowance = IERC20(_lpToken).allowance(account, address(this));
        pendingToken = pendingTokenReward(account) + user.calTokenReward;
        pendingLP = pendingLPReward(account) + user.calLPReward;
        pendingMintReward = _calPendingMintReward(account) + user.calMintReward;
    }

    function getUserExtInfo(address account) public view returns (
        uint256 calTokenReward, uint256 rewardTokenDebt,
        uint256 calLPReward, uint256 rewardLPDebt,
        uint256 calMintReward, uint256 rewardMintDebt
    ) {
        UserInfo storage user = userInfo[account];
        calTokenReward = user.calTokenReward;
        rewardTokenDebt = user.rewardTokenDebt;
        calLPReward = user.calLPReward;
        rewardLPDebt = user.rewardLPDebt;
        calMintReward = user.calMintReward;
        rewardMintDebt = user.rewardMintDebt;
    }

    function getBaseInfo() external view returns (
        address lpToken,
        uint256 lpTokenDecimals,
        string memory lpTokenSymbol,
        address rewardToken,
        uint256 rewardTokenDecimals,
        string memory rewardTokenSymbol,
        address mintRewardToken,
        uint256 mintRewardTokenDecimals,
        string memory mintRewardTokenSymbol
    ){
        lpToken = _lpToken;
        lpTokenDecimals = IERC20(lpToken).decimals();
        lpTokenSymbol = _lpTokenSymbol;
        rewardToken = _rewardToken;
        rewardTokenDecimals = IERC20(rewardToken).decimals();
        rewardTokenSymbol = IERC20(rewardToken).symbol();
        mintRewardToken = _mintRewardToken;
        mintRewardTokenDecimals = IERC20(mintRewardToken).decimals();
        mintRewardTokenSymbol = IERC20(mintRewardToken).symbol();
    }

    function getBinderLength(address account) public view returns (uint256){
        return _binder[account].length;
    }

    function setLPToken(address lpToken, string memory lpSymbol) external onlyOwner {
        require(poolInfo.totalAmount == 0, "started");
        _lpToken = lpToken;
        _lpTokenSymbol = lpSymbol;
    }

    function setRewardToken(address rewardToken) external onlyOwner {
        _rewardToken = rewardToken;
    }

    function setMintRewardToken(address rewardToken) external onlyOwner {
        _mintRewardToken = rewardToken;
    }

    function setMintPerBlock(uint256 mintPerBlock) external onlyOwner {
        _updatePool();
        poolInfo.mintPerBlock = mintPerBlock;
    }

    function setTotalMintReward(uint256 totalReward) external onlyOwner {
        _updatePool();
        poolInfo.totalMintReward = totalReward;
    }

    function setInviteFee(uint256 fee) external onlyOwner {
        _inviteFee = fee;
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(address token, address to, uint256 amount) external onlyOwner {
        if (token == _lpToken) {
            return;
        }
        IERC20(token).transfer(to, amount);
    }
}

contract LPDividendPool is AbsLPPool {
    constructor() AbsLPPool(
    //ZM-USDT-LP
        address(0xfF69aCcF887b04246e7FF6e91e80Fa7123D2D138),
        "ZM-USDT-LP",
    //ZM
        address(0x4ec59bbE3D46473C4fcCecaF7ddBe8d80d1767A8),
    //ZM2
        address(0x846F4195a3Ad6D0e654892026462d9984bA4aa6E)
    ){

    }
}