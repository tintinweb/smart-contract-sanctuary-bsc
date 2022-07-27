/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

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

interface IToken {
    function bindInvitor(address account, address invitor) external;

    function _inviter(address account) external view returns (address);

    function getBinderLength(address account) external view returns (uint256);

    function _teamNum(address account) external view returns (uint256);

    function _binders(address account, uint256 index) external view returns (address);
}

interface INodePool {
    function addAmount(address account, uint256 amount) external;

    function minusAmount(address account, uint256 amount) external;
}

abstract contract AbsMintPool is Ownable {
    struct UserInfo {
        bool active;
        //U本位算力
        uint256 amount;
        uint256 lpAmount;
        uint256 startBlock;
        uint256 pendingInviteReward;
        uint256 claimedInviteReward;
        uint256 claimedReward;
        uint256 rewardPerBlock;
        uint256 totalClaimed;
    }

    address private _usdtAddress;
    address private _tokenAddress;
    address private _lpTokenAddress;

    address public _fundAddress;

    mapping(address => UserInfo) private _userInfo;

    uint256 private _minAmount;

    uint256 public _inviteFee = 10000;
    uint256 public _inviteFee1 = 1000;
    uint256 public _rewardRate = 200;

    bool  private _pause;

    address[] public _userList;
    mapping(address => uint256) public _userIndex;

    uint256 public _inviteLength = 10;

    uint256 public constant _feeDivFactor = 10000;

    address public _nodePool;
    uint256 private _totalUAmount;
    uint256 private _totalLPAmount;

    constructor(address UsdtAddress, address TokenAddress, address LPAddress, address FundAddress, address NodePool){
        _usdtAddress = UsdtAddress;
        _tokenAddress = TokenAddress;
        _lpTokenAddress = LPAddress;
        _fundAddress = FundAddress;
        _nodePool = NodePool;

        uint256 usdtDecimals = 10 ** IERC20(UsdtAddress).decimals();
        _minAmount = 200 * usdtDecimals;
    }

    function stake(uint256 lpAmount, address invitor) external {
        require(!_pause, "Pause");
        uint256 uAmount = lpUValue(lpAmount);
        require(uAmount >= _minAmount, "lt minAmount");

        address account = msg.sender;
        require(account == tx.origin, "not origin");

        UserInfo storage userInfo = _userInfo[account];
        IToken token = IToken(_tokenAddress);
        if (!userInfo.active) {
            if (address(0) != invitor && _userInfo[invitor].active) {
                token.bindInvitor(account, invitor);
            }
            _addUser(account);
            userInfo.active = true;
        }

        _claimReward(account);

        userInfo.amount += uAmount;
        userInfo.lpAmount += lpAmount;
        _takeToken(_lpTokenAddress, account, lpAmount);

        uint256 newUAmount = userInfo.amount;
        //每日收益/每日区块
        uint256 rewardPerBlock = newUAmount * 1e12 * _rewardRate / _feeDivFactor / 28800;
        userInfo.startBlock = block.number;
        userInfo.claimedReward = 0;
        userInfo.rewardPerBlock = rewardPerBlock;

        INodePool(_nodePool).addAmount(account, uAmount);

        _totalUAmount += uAmount;
        _totalLPAmount += lpAmount;
    }

    function unStake() external {
        require(msg.sender == tx.origin, "not origin");
        _unStake(true);
    }

    function emergencyWithdraw() external {
        _unStake(false);
    }

    function _unStake(bool getReward) internal {
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        if (getReward) {
            _claimReward(account);
        }

        uint256 uAmount = userInfo.amount;
        uint256 lpAmount = userInfo.lpAmount;
        _giveToken(_lpTokenAddress, account, lpAmount);

        userInfo.startBlock = block.number;
        userInfo.claimedReward = 0;
        userInfo.rewardPerBlock = 0;

        INodePool(_nodePool).minusAmount(account, uAmount);
        _totalUAmount -= uAmount;
        _totalLPAmount -= lpAmount;
    }

    function claimReward() external {
        require(msg.sender == tx.origin, "not origin");
        _claimReward(msg.sender);
    }

    function claimInviteReward(address account) public {
        UserInfo storage userInfo = _userInfo[account];
        uint256 pendingInviteReward = userInfo.pendingInviteReward;
        userInfo.pendingInviteReward = 0;
        userInfo.claimedInviteReward += pendingInviteReward;
        _giveToken(_tokenAddress, account, pendingInviteReward);
    }

    function _claimReward(address account) private {
        uint256 pendingUsdt = _getPendingUsdt(account);
        if (pendingUsdt > 0) {
            UserInfo storage userInfo = _userInfo[account];
            userInfo.claimedReward += pendingUsdt;
            uint256 pendingReward = tokenAmountOut(pendingUsdt);
            userInfo.totalClaimed += pendingReward;
            _giveToken(_tokenAddress, account, pendingReward);
            uint256 accountAmount = userInfo.amount;

            address current = account;
            address invitor;
            IToken token = IToken(_tokenAddress);
            UserInfo storage invitorInfo;
            uint256 len = _inviteLength;
            uint256 invitorAmount;
            uint256 inviteReward = pendingReward * _inviteFee1 / _feeDivFactor;
            for (uint256 i; i < len;) {
                invitor = token._inviter(current);
                if (address(0) == invitor) {
                    break;
                }
                invitorInfo = _userInfo[invitor];
                invitorAmount = invitorInfo.amount;
                if (0 == i) {
                    uint256 pendingReward0 = pendingReward * _inviteFee / _feeDivFactor;
                    if (accountAmount > invitorAmount) {
                        pendingReward0 = pendingReward0 * invitorAmount / accountAmount;
                    }
                    invitorInfo.pendingInviteReward += pendingReward0;
                } else {
                    uint256 binderLength = token.getBinderLength(invitor);
                    if (binderLength > i) {
                        if (accountAmount > invitorAmount) {
                            invitorInfo.pendingInviteReward += inviteReward * invitorAmount / accountAmount;
                        } else {
                            invitorInfo.pendingInviteReward += inviteReward;
                        }
                    }
                }
                current = invitor;
            unchecked{
                ++i;
            }
            }
        }
    }

    function _takeToken(address tokenAddress, address account, uint256 amount) private {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(account) >= amount, "token balance not enough");
        token.transferFrom(account, address(this), amount);
    }

    function _giveToken(address tokenAddress, address account, uint256 amount) private {
        if (0 == amount) {
            return;
        }
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "pool token not enough");
        token.transfer(account, amount);
    }

    function _getPendingUsdt(address account) private view returns (uint256 pendingUsdt){
        UserInfo storage userInfo = _userInfo[account];
        uint256 claimedReward = userInfo.claimedReward;
        uint256 reward = userInfo.rewardPerBlock * (block.number - userInfo.startBlock) / 1e12;
        if (reward > claimedReward) {
            pendingUsdt = reward - claimedReward;
        }
    }

    function _addUser(address adr) private {
        if (0 == _userIndex[adr]) {
            if (0 == _userList.length || _userList[0] != adr) {
                _userIndex[adr] = _userList.length;
                _userList.push(adr);
            }
        }
    }

    receive() external payable {}

    function getPoolInfo() external view returns (
        address lpAddress, uint256 lpDecimals,
        uint256 totalUAmount, uint256 totalLPAmount, uint256 totalLPUAmount,
        bool pause, uint256 minAmount, uint256 lpPrice
    ){
        lpAddress = _lpTokenAddress;
        lpDecimals = IERC20(lpAddress).decimals();
        totalUAmount = _totalUAmount;
        totalLPAmount = _totalLPAmount;
        totalLPUAmount = lpUValue(totalLPAmount);
        pause = _pause;
        minAmount = _minAmount;
        lpPrice = getLPPrice();
    }

    function getPoolExtInfo() external view returns (
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address tokenAddress, uint256 tokenDecimals, string memory toienSymbol
    ){
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        toienSymbol = IERC20(tokenAddress).symbol();
    }

    function getUserInfo(address account) external view returns (
        bool active,
    //U本位算力
        uint256 amount,
        uint256 lpAmount,
        uint256 pendingInviteReward,
        uint256 claimedInviteReward,
        uint256 pendingReward,
        uint256 lpBalance
    ){
        UserInfo storage userInfo = _userInfo[account];
        active = userInfo.active;
        amount = userInfo.amount;
        lpAmount = userInfo.lpAmount;
        pendingInviteReward = userInfo.pendingInviteReward;
        claimedInviteReward = userInfo.claimedInviteReward;
        uint256 pendingUsdt = _getPendingUsdt(account);
        pendingReward = tokenAmountOut(pendingUsdt);
        lpBalance = IERC20(_lpTokenAddress).balanceOf(account);
    }

    function getUserExtInfo(address account) external view returns (
        uint256 startBlock,
        uint256 claimedReward,
        uint256 rewardPerBlock,
        uint256 totalClaimed
    ){
        UserInfo storage userInfo = _userInfo[account];
        startBlock = userInfo.startBlock;
        claimedReward = userInfo.claimedReward;
        rewardPerBlock = userInfo.rewardPerBlock;
        totalClaimed = userInfo.totalClaimed;
    }

    function getUserListLength() public view returns (uint256){
        return _userList.length;
    }

    function setAddress(address usdtAddress, address tokenAddress, address lpAddress) external onlyOwner {
        _usdtAddress = usdtAddress;
        _tokenAddress = tokenAddress;
        _lpTokenAddress = lpAddress;
    }

    function setLimit(uint256 minAmount) external onlyOwner {
        _minAmount = minAmount * 10 ** IERC20(_usdtAddress).decimals();
    }

    function setInviteFee(uint256 inviteFee, uint256 inviteFee1) external onlyOwner {
        _inviteFee = inviteFee;
        _inviteFee1 = inviteFee1;
    }

    function setFundAddress(address adr) external onlyOwner {
        _fundAddress = adr;
    }

    function setNodePool(address adr) external onlyOwner {
        _nodePool = adr;
    }

    function setPause(bool pause) external onlyOwner {
        _pause = pause;
    }

    function setRewardRate(uint256 rewardRate) external onlyOwner {
        _rewardRate = rewardRate;
    }

    function setInviteLength(uint256 length) external onlyOwner {
        _inviteLength = length;
    }

    function tokenAmountOut(uint256 usdtAmount) public view returns (uint256){
        uint256 tokenBalance = IERC20(_tokenAddress).balanceOf(_lpTokenAddress);
        uint256 usdtBalance = IERC20(_usdtAddress).balanceOf(_lpTokenAddress);
        if (0 == usdtBalance) {
            return 0;
        }
        return usdtAmount * tokenBalance / usdtBalance;
    }

    function tokenPrice() public view returns (uint256){
        uint256 tokenBalance = IERC20(_tokenAddress).balanceOf(_lpTokenAddress);
        uint256 usdtBalance = IERC20(_usdtAddress).balanceOf(_lpTokenAddress);
        if (0 == tokenBalance) {
            return 0;
        }
        return 10 ** IERC20(_tokenAddress).decimals() * usdtBalance / tokenBalance;
    }

    function lpUValue(uint256 lpAmount) public view returns (uint256){
        IERC20 lp = IERC20(_lpTokenAddress);
        uint256 total = lp.totalSupply();
        uint256 usdtBalance = IERC20(_usdtAddress).balanceOf(_lpTokenAddress);
        if (0 == total) {
            return 0;
        }
        return usdtBalance * 2 * lpAmount / total;
    }

    function getLPPrice() public view returns (uint256){
        IERC20 lp = IERC20(_lpTokenAddress);
        uint256 total = lp.totalSupply();
        if (0 == total) {
            return 0;
        }
        uint256 usdtBalance = IERC20(_usdtAddress).balanceOf(_lpTokenAddress);
        return usdtBalance * 2 * 10 ** lp.decimals() / total;
    }

    function claimBalance(uint256 amount, address to) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }
}

contract LPUMintPool is AbsMintPool {
    constructor() AbsMintPool(
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Token
        address(0x69097995E7296732D1203C05E74299349D14D0BF),
    //LP
        address(0xDBf78f06F2b8040F4A7b91D48c1971c55A11Fbf4),
    //Fund
        address(0xC1772d21b47431912D907b1a03dA7c4552E129f8),
    //NodePool
        address(0x5E86d7D033D24aAb1d9B92f274b0A6c8409Ba1f6)
    ){

    }
}