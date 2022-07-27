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

interface IToken {
    function bindInvitor(address account, address invitor) external;

    function _inviter(address account) external view returns (address);

    function getBinderLength(address account) external view returns (uint256);

    function _teamNum(address account) external view returns (uint256);

    function _binders(address account, uint256 index) external view returns (address);
}

abstract contract AbsPool is Ownable {
    struct UserInfo {
        //是否节点
        bool isNode;
        //自己质押的算力
        uint256 amount;
        //团队算力
        uint256 teamAmount;
        //总释放奖励
        uint256 totalReward;
        //已领取奖励
        uint256 claimedReward;
    }

    address private _usdtAddress;
    address public _cashAddress;
    address private _tokenAddress;

    bool private _pauseClaim = true;

    mapping(address => UserInfo) private _userInfo;
    uint256 public _inviteFee = 20;
    uint256 private _maxReward;
    uint256[2][] private _rewardCondition;

    address[] private _nodeList;

    address public _lpPool;

    constructor(address USDTAddress, address TokenAddress, address CashAddress){
        _usdtAddress = USDTAddress;
        _cashAddress = CashAddress;
        _tokenAddress = TokenAddress;

        uint256 usdtDecimals = 10 ** IERC20(USDTAddress).decimals();
        _rewardCondition.push([uint256(200000 * usdtDecimals), 100]);
        _rewardCondition.push([uint256(100000 * usdtDecimals), 70]);
        _rewardCondition.push([uint256(50000 * usdtDecimals), 30]);
        _rewardCondition.push([uint256(20000 * usdtDecimals), 10]);

        uint256 tokenDecimals = 10 ** IERC20(TokenAddress).decimals();
        _maxReward = 100000000 * tokenDecimals;
    }

    function addAmount(address account, uint256 amount) external onlyLPPool {
        UserInfo storage userInfo = _userInfo[account];
        userInfo.amount += amount;
        if (userInfo.isNode) {
            amount = amount * _inviteFee / 100;
        }

        IToken token = IToken(_tokenAddress);
        address current = account;
        address invitor;
        UserInfo storage invitorInfo;
        for (uint256 i; i < 10;) {
            invitor = token._inviter(current);
            if (address(0) == invitor) {
                break;
            }
            invitorInfo = _userInfo[invitor];
            if (invitorInfo.isNode && invitorInfo.amount > 0) {
                invitorInfo.teamAmount += amount;
                invitorInfo.totalReward = _maxReward * getRewardRate(invitorInfo.teamAmount) / 100;
            }
            current = invitor;
        unchecked{
            amount = amount * _inviteFee / 100;
            ++i;
        }
        }
    }

    function minusAmount(address account, uint256 amount) external onlyLPPool {
        UserInfo storage userInfo = _userInfo[account];
        userInfo.amount = 0;
        if (userInfo.isNode) {
            amount = amount * _inviteFee / 100;
            userInfo.teamAmount = 0;
        }

        IToken token = IToken(_tokenAddress);
        address current = account;
        address invitor;
        UserInfo storage invitorInfo;
        for (uint256 i; i < 10;) {
            invitor = token._inviter(current);
            if (address(0) == invitor) {
                break;
            }
            invitorInfo = _userInfo[invitor];
            uint256 teamAmount = invitorInfo.teamAmount;
            if (invitorInfo.isNode && invitorInfo.teamAmount > 0) {
                if (teamAmount > amount) {
                    invitorInfo.teamAmount -= amount;
                } else {
                    invitorInfo.teamAmount = 0;
                }
            }
            current = invitor;
        unchecked{
            amount = amount * _inviteFee / 100;
            ++i;
        }
        }
    }

    function getRewardRate(uint256 teamAmount) public view returns (uint256 reward){
        uint256 len = _rewardCondition.length;
        for (uint256 i; i < len;) {
            if (teamAmount >= _rewardCondition[i][0]) {
                reward = _rewardCondition[i][1];
                break;
            }
        unchecked{
            ++i;
        }
        }
    }

    function claim() external {
        require(!_pauseClaim, "pauseClaim");
        address account = msg.sender;
        UserInfo storage userInfo = _userInfo[account];
        uint256 totalReward = userInfo.totalReward;
        uint256 claimedReward = userInfo.claimedReward;
        uint256 pendingToken;
        if (totalReward > claimedReward) {
            pendingToken = totalReward - claimedReward;
        }
        userInfo.claimedReward += pendingToken;
        IERC20(_tokenAddress).transfer(account, pendingToken);
    }

    function getPoolInfo() external view returns (
        uint256 maxReward, bool pauseClaim,
        address usdtAddress, uint256 usdtDecimals, string memory usdtSymbol,
        address tokenAddress, uint256 tokenDecimals, string memory tokenSymbol
    ) {
        maxReward = _maxReward;
        pauseClaim = _pauseClaim;
        usdtAddress = _usdtAddress;
        usdtDecimals = IERC20(usdtAddress).decimals();
        usdtSymbol = IERC20(usdtAddress).symbol();
        tokenAddress = _tokenAddress;
        tokenDecimals = IERC20(tokenAddress).decimals();
        tokenSymbol = IERC20(tokenAddress).symbol();
    }

    function getUserInfo(address account) external view returns (
        bool isNode,
    //自己质押的算力
        uint256 amount,
    //团队算力
        uint256 teamAmount,
    //总释放奖励
        uint256 totalReward,
    //已领取奖励
        uint256 claimedReward,
    //团队人数
        uint256 teamNum
    ) {
        UserInfo storage userInfo = _userInfo[account];
        isNode = isNode;
        amount = userInfo.amount;
        teamAmount = userInfo.teamAmount;
        totalReward = userInfo.totalReward;
        claimedReward = userInfo.claimedReward;
        teamNum = IToken(_tokenAddress)._teamNum(account);
    }

    function getBinderList(address account, uint256 start, uint256 length) public view returns (
        uint256 returnLen, address[] memory binders, uint256[] memory binderAmounts, uint256[] memory binderCounts
    ){
        IToken token = IToken(_tokenAddress);
        uint256 binderLength = token.getBinderLength(account);
        if (0 == length) {
            length = binderLength;
        }
        returnLen = length;

        binders = new address[](length);
        binderAmounts = new uint256[](length);
        binderCounts = new uint256[](length);

        uint256 index = 0;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= binderLength)
                return (index, binders, binderAmounts, binderCounts);
            address binder = token._binders(account, i);
            binders[index] = binder;
            binderAmounts[index] = _userInfo[binder].amount;
            binderCounts[index] = token.getBinderLength(binder);
            ++index;
        }
    }

    receive() external payable {}

    function claimBalance(uint256 amount, address to) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20 erc20 = IERC20(token);
        erc20.transfer(to, amount);
    }

    function setCashAddress(address cashAddress) external onlyOwner {
        _cashAddress = cashAddress;
    }

    function setUsdtAddress(address usdtAddress) external onlyOwner {
        _usdtAddress = usdtAddress;
    }

    function setTokenAddress(address tokenAddress) external onlyOwner {
        _tokenAddress = tokenAddress;
    }

    function setMaxReward(uint256 amount) external onlyOwner {
        _maxReward = amount * 10 ** IERC20(_tokenAddress).decimals();
    }

    function setInviteFee(uint256 fee) external onlyOwner {
        _inviteFee = fee;
    }

    function setPauseClaim(bool pauseClaim) external onlyOwner {
        _pauseClaim = pauseClaim;
    }

    function setRewardCondition(uint256[2][] memory rewardCondition) external onlyOwner {
        _rewardCondition = rewardCondition;
    }

    function getRewardCondition() external view returns (uint256[2][] memory rewardCondition){
        rewardCondition = _rewardCondition;
    }

    function setLPPool(address lpPool) external onlyOwner {
        _lpPool = lpPool;
    }

    function addNode(address adr) external onlyOwner {
        _nodeList.push(adr);
        _userInfo[adr].isNode = true;
    }

    function setNodeList(address[] memory adrList) external onlyOwner {
        uint256 len = _nodeList.length;
        address adr;
        //清除旧节点列表
        for (uint256 i; i < len;) {
            adr = _nodeList[i];
            _userInfo[adr].isNode = false;
        unchecked{
            ++i;
        }
        }
        //添加新节点列表
        len = adrList.length;
        for (uint256 i; i < len;) {
            adr = adrList[i];
            _userInfo[adr].isNode = true;
        unchecked{
            ++i;
        }
        }

        _nodeList = adrList;
    }

    function getNodeList() external view returns (address[] memory){
        return _nodeList;
    }

    modifier onlyLPPool() {
        require(_lpPool == msg.sender, "!LPPool");
        _;
    }
}

contract NodePool is AbsPool {
    constructor() AbsPool(
    //USDT
        address(0x55d398326f99059fF775485246999027B3197955),
    //Token
        address(0x69097995E7296732D1203C05E74299349D14D0BF),
    //Cash
        address(0xC1772d21b47431912D907b1a03dA7c4552E129f8)
    ){

    }
}