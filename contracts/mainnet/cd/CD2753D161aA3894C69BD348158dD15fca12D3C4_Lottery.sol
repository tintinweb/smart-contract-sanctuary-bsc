/**
 *Submitted for verification at BscScan.com on 2022-06-04
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
        require(_owner == msg.sender, "not owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "0 owner");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IRelationShip {
    function bindInvitor(address account, address invitor) external;

    function _inviter(address account) external view returns (address);
}

interface IRootNodePool {
    function getUserPoolInfo(uint256 pid, address account) external view returns (uint256 amount, uint256 pending);
}

contract Lottery is Ownable {
    struct LotteryPool {
        uint256 max;
        uint256 price;
        uint256 currentIndex;
    }

    struct UserInfo {
        uint256 pendingInviteReward;
        uint256 claimedInviteReward;
        uint256 pendingPoolReward;
        uint256 claimedPoolReward;
    }

    struct InviteRewardRecord {
        uint256 reward;
        uint256 time;
    }

    struct NodePool {
        uint256 accPerShare;
        uint256 totalAmount;
        uint256 accReward;
    }

    struct UserNodePool {
        uint256 amount;
        uint256 rewardDebt;
    }

    //pid => index =>soldCount
    mapping(uint256 => mapping(uint256 => uint256)) private _indexSoldCount;
    //pid => index =>num=>address
    mapping(uint256 => mapping(uint256 => mapping(uint256 => address))) private _indexNumAddress;
    //pid =>index =>rewardNum[]
    mapping(uint256 => mapping(uint256 => uint256[])) private _indexRewardNum;
    //pid => address => pendingReward
    mapping(uint256 => mapping(address => uint256)) private _pendingLotteryReward;
    //pid => LotteryPool
    mapping(uint256 => LotteryPool) _lotteryPool;
    uint256 public _lotteryPoolLength;

    bool public _enableOpen = true;

    uint256 private _inviteFee = 100;
    uint256 private _inviteFee1 = 50;
    uint256 private _dividendFee = 300;
    uint256 private _totalFee = 600;

    mapping(uint256 => uint256) private _dividendRate;

    address public _relationShip;
    address public _fundAddress;
    address public _nodePoolAddress;

    mapping(address => UserInfo) private _userInfo;
    mapping(address => InviteRewardRecord[]) private _userInviteRewardRecord;

    uint256 public _nodePoolLength;
    mapping(uint256 => NodePool) private _nodePool;
    mapping(uint256 => mapping(address => UserNodePool)) private _userNodePool;

    function buy(uint256 pid, address invitor) external payable {
        address account = msg.sender;
        if (tx.origin != account) {
            return;
        }
        require(_enableOpen, "notOpen");
        require(pid < _lotteryPoolLength, "notPid");
        IRelationShip relationShip = IRelationShip(_relationShip);
        relationShip.bindInvitor(account, invitor);

        LotteryPool storage lotteryPool = _lotteryPool[pid];
        uint256 price = lotteryPool.price;
        require(msg.value >= price, "payNotEnough");

        uint256 currentIndex = lotteryPool.currentIndex;
        uint256 no = _indexSoldCount[pid][currentIndex];
        _indexNumAddress[pid][currentIndex][no] = account;
        no++;
        _indexSoldCount[pid][currentIndex] = no;

        uint256 fundAmount = price * _totalFee / 10000;
        uint256 rewardAmount = price - fundAmount;

        uint256 time = block.timestamp;
        invitor = relationShip._inviter(account);
        if (address(0) != invitor) {
            uint256 inviteAmount = price * _inviteFee / 10000;
            if (inviteAmount > 0) {
                fundAmount -= inviteAmount;
                _userInfo[invitor].pendingInviteReward += inviteAmount;
                _userInviteRewardRecord[invitor].push(InviteRewardRecord(inviteAmount, time));
            }
            invitor = relationShip._inviter(invitor);
            if (address(0) != invitor) {
                inviteAmount = price * _inviteFee1 / 10000;
                if (inviteAmount > 0) {
                    fundAmount -= inviteAmount;
                    _userInfo[invitor].pendingInviteReward += inviteAmount;
                    _userInviteRewardRecord[invitor].push(InviteRewardRecord(inviteAmount, time));
                }
            }
        }

        uint256 poolLength = _nodePoolLength;
        uint256 poolAllNewReward = price * _dividendFee / 10000;
        for (uint256 i; i < poolLength;) {
            uint256 consumeReward = _updateNodePool(i, poolAllNewReward * _dividendRate[i] / 10000);
            fundAmount -= consumeReward;
        unchecked{
            ++i;
        }
        }

        _fundAddress.call{value : fundAmount}("");

        uint256 max = lotteryPool.max;
        if (max == no) {
            _open(pid, currentIndex, max, rewardAmount);
        }
    }

    uint256 private _random;

    function _open(uint256 pid, uint256 currentIndex, uint256 max, uint256 rewardAmount) private {
        uint256[] memory nos = new uint256[](max);
        for (uint256 i; i < max;) {
            nos[i] = i;
        unchecked{
            ++i;
        }
        }
        uint256 random = uint256(keccak256(abi.encode(_random, _indexNumAddress[pid][currentIndex][0], block.number + pid + max + currentIndex + rewardAmount)));
        uint256 index;
        uint256 rewardNum = max - 1;
        uint256 no;
        address account;
        uint256 reward = rewardAmount * max / rewardNum;
        for (uint256 i = 0; i < rewardNum; ++i) {
            index = uint32(random) % (max - i);
            no = nos[index];
            account = _indexNumAddress[pid][currentIndex][no];
            _pendingLotteryReward[pid][account] += reward;
            _indexRewardNum[pid][currentIndex].push(no);
            nos[index] = nos[max - 1 - i];
            random = random >> 1;
        }
    unchecked{
        ++currentIndex;
    }
        _lotteryPool[pid].currentIndex = currentIndex;
        _random = random;
    }

    function _updateNodePool(uint256 pid, uint256 reward) private returns (uint256){
        NodePool storage poolInfo = _nodePool[pid];
        if (reward > 0 && poolInfo.totalAmount > 0) {
            poolInfo.accPerShare += reward * 1e12 / poolInfo.totalAmount;
            poolInfo.accReward += reward;
            return reward;
        }
        return 0;
    }

    function _pendingNodeReward(uint256 pid, address account) private view returns (uint256 reward) {
        reward = 0;
        NodePool storage poolInfo = _nodePool[pid];
        UserNodePool storage userPoolInfo = _userNodePool[pid][account];
        uint256 userAmount = userPoolInfo.amount;
        if (0 == userAmount) {
            (userAmount,) = IRootNodePool(_nodePoolAddress).getUserPoolInfo(pid, account);
        }
        if (userAmount > 0) {
            reward = userAmount * poolInfo.accPerShare / 1e12 - userPoolInfo.rewardDebt;
        }
    }

    function getNodePoolInfo(uint256 pid) public view returns (uint256 amount, uint256 reward) {
        NodePool storage poolInfo = _nodePool[pid];
        amount = poolInfo.totalAmount;
        reward = poolInfo.accReward;
    }

    function getAllNodePoolInfo() public view returns (uint256[] memory amount, uint256[] memory reward) {
        uint256 poolLen = _nodePoolLength;
        amount = new uint256[](poolLen);
        reward = new uint256[](poolLen);
        for (uint256 i; i < poolLen; ++i) {
            (amount[i], reward[i]) = getNodePoolInfo(i);
        }
    }

    function getUserNodePoolInfo(uint256 pid, address account) public view returns (uint256 amount, uint256 pending) {
        UserNodePool storage user = _userNodePool[pid][account];
        amount = user.amount;
        pending = _pendingNodeReward(pid, account);
    }

    function getUserAllNodePoolInfo(address account) public view returns (uint256[] memory amount, uint256[] memory pending) {
        uint256 poolLen = _nodePoolLength;
        amount = new uint256[](poolLen);
        pending = new uint256[](poolLen);
        for (uint256 i; i < poolLen; ++i) {
            (amount[i], pending[i]) = getUserNodePoolInfo(i, account);
        }
    }

    function getUserInfo(address account) external view returns (
        uint256 pendingInviteReward, uint256 claimedInviteReward,
        uint256 pendingPoolReward, uint256 claimedPoolReward){
        UserInfo storage userInfo = _userInfo[account];
        pendingInviteReward = userInfo.pendingInviteReward;
        claimedInviteReward = userInfo.claimedInviteReward;
        pendingPoolReward = userInfo.pendingPoolReward;
        claimedPoolReward = userInfo.claimedPoolReward;
        uint256 poolLen = _nodePoolLength;
        for (uint256 i; i < poolLen;) {
            (,uint256 pending) = getUserNodePoolInfo(i, account);
            pendingPoolReward += pending;
        unchecked{
            ++i;
        }
        }
    }

    function getInviteRewardRecordLen(address account) external view returns (uint256){
        return _userInviteRewardRecord[account].length;
    }

    function getInviteRewardRecord(address account, uint256 start, uint256 length) external view returns (uint256 returnLen, uint256[] memory reward, uint256[] memory time){
        uint256 total = _userInviteRewardRecord[account].length;
        if (0 == length) {
            length = total;
        }
        returnLen = length;

        reward = new uint256[](length);
        time = new uint256[](length);
        uint256 index = 0;
        InviteRewardRecord storage record;
        for (uint256 i = start; i < start + length; ++i) {
            if (i >= total)
                return (index, reward, time);
            record = _userInviteRewardRecord[account][i];
            reward[index] = record.reward;
            time[index] = record.time;
            ++index;
        }
    }

    function claimLottery(uint256 pid, address account) external {
        uint256 reward = _pendingLotteryReward[pid][account];
        _pendingLotteryReward[pid][account] = 0;
        address payable addr = payable(account);
        addr.transfer(reward);
    }

    function pendingLotteryReward(uint256 pid, address account) public view returns (uint256 reward){
        reward = _pendingLotteryReward[pid][account];
    }

    function allPendingLotteryReward(address account) external view returns (uint256[] memory reward){
        uint256 len = _lotteryPoolLength;
        reward = new uint256[](len);
        for (uint i; i < len; ++i) {
            reward[i] = pendingLotteryReward(i, account);
        }
    }

    function claimReward(address account) external {
        uint256 poolLen = _nodePoolLength;
        for (uint256 i; i < poolLen;) {
            UserNodePool storage userNodePool = _userNodePool[i][account];
            if (0 == userNodePool.amount) {
                (userNodePool.amount,) = IRootNodePool(_nodePoolAddress).getUserPoolInfo(i, account);
            }
            _transferReward(_nodePool[i], userNodePool, account);
        unchecked{
            ++i;
        }
        }
        UserInfo  storage userInfo = _userInfo[account];
        uint256 pendingInviteReward = userInfo.pendingInviteReward;
        userInfo.pendingInviteReward = 0;
        userInfo.claimedInviteReward += pendingInviteReward;
        uint256 pendingPoolReward = userInfo.pendingPoolReward;
        userInfo.pendingPoolReward = 0;
        userInfo.claimedPoolReward += pendingPoolReward;
        address payable addr = payable(account);
        addr.transfer(pendingInviteReward + pendingPoolReward);
    }

    function _transferReward(NodePool storage poolInfo, UserNodePool storage userPoolInfo, address account) private {
        if (userPoolInfo.amount > 0) {
            uint256 accReward = userPoolInfo.amount * poolInfo.accPerShare / 1e12;
            uint256 pendingAmount = accReward - userPoolInfo.rewardDebt;
            if (pendingAmount > 0) {
                userPoolInfo.rewardDebt = accReward;
                UserInfo storage userInfo = _userInfo[account];
                userInfo.pendingPoolReward += pendingAmount;
            }
        }
    }

    function lotteryIndexInfo(uint256 pid, uint256 index) external view returns (address[] memory addrs, uint256[] memory rewardNum) {
        uint256 count = _indexSoldCount[pid][index];
        addrs = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            addrs[i] = _indexNumAddress[pid][index][i];
        }
        rewardNum = _indexRewardNum[pid][index];
    }

    function getLotteryPool(uint256 pid) public view returns (
        uint256 price, uint256 max, uint256 currentIndex, bool enableOpen, uint256 soldCount
    ) {
        LotteryPool storage lotteryPool = _lotteryPool[pid];
        price = lotteryPool.price;
        max = lotteryPool.max;
        currentIndex = lotteryPool.currentIndex;
        enableOpen = _enableOpen;
        soldCount = _indexSoldCount[pid][currentIndex];
    }

    function getAllLotteryPool() external view returns (
        uint256[] memory price, uint256[] memory max, uint256[] memory currentIndex,
        bool[] memory enableOpen, uint256[] memory soldCount
    ) {
        uint256 len = _lotteryPoolLength;
        price = new uint256[](len);
        max = new uint256[](len);
        currentIndex = new uint256[](len);
        enableOpen = new bool[](len);
        soldCount = new uint256[](len);
        for (uint i; i < len; ++i) {
            (price[i], max[i], currentIndex[i], enableOpen[i], soldCount[i]) = getLotteryPool(i);
        }
    }

    function setPrice(uint256 pid, uint256 price) external onlyOwner {
        _lotteryPool[pid].price = price;
    }

    function setMax(uint256 pid, uint256 max) external onlyOwner {
        _lotteryPool[pid].max = max;
    }

    function setEnableOpen(bool e) external onlyOwner {
        _enableOpen = e;
    }

    function setFee(uint256 inviteFee, uint256 inviteFee1, uint256 dividendFee, uint256 totalFee) external onlyOwner {
        _inviteFee = inviteFee;
        _inviteFee1 = inviteFee1;
        _dividendFee = dividendFee;
        _totalFee = totalFee;
    }

    function setDividendRate(uint256[] memory rate) external onlyOwner {
        uint256 len = rate.length;
        require(len == _nodePoolLength, "notLen");
        uint256 total;
        for (uint256 i; i < len;) {
            _dividendRate[i] = rate[i];
            total += rate[i];
        unchecked{
            ++i;
        }
        }
        require(10000 == total, "not10000");
    }

    function setFundAddress(address adr) external onlyOwner {
        _fundAddress = adr;
    }

    function withdrawERC20(address erc20Address, address account, uint256 amount) external onlyOwner {
        IERC20 erc20 = IERC20(erc20Address);
        erc20.transfer(account, amount);
    }

    function withdrawBalance(address account, uint256 amount) external onlyOwner {
        address payable addr = payable(account);
        addr.transfer(amount);
    }

    receive() external payable {}

    function onNodePoolChanged(
        uint256 pid, uint256 totalAmount,
        address account, uint256 amount, uint256 beforeAmount
    ) external {
        require(msg.sender == _nodePoolAddress, "notNodePool");
        NodePool storage nodePool = _nodePool[pid];
        nodePool.totalAmount = totalAmount;

        if (address(0) == account) {
            return;
        }

        UserNodePool storage userNodePool = _userNodePool[pid][account];
        if (userNodePool.amount == 0 && beforeAmount != 0) {
            userNodePool.amount = beforeAmount;
        }
        _transferReward(nodePool, userNodePool, account);
        userNodePool.amount = amount;
        userNodePool.rewardDebt = amount * nodePool.accPerShare / 1e12;
    }

    function getFee() external view returns (uint256 inviteFee, uint256 inviteFee1, uint256 dividendFee, uint256 totalFee){
        inviteFee = _inviteFee;
        inviteFee1 = _inviteFee1;
        dividendFee = _dividendFee;
        totalFee = _totalFee;
    }

    function getDividendRate() external view returns (uint256[] memory rates){
        rates = new uint256[](_nodePoolLength);
        for (uint256 i; i < _nodePoolLength; ++i) {
            rates[i] = _dividendRate[i];
        }
    }

    constructor(){
        _relationShip = address(0xb863EDC5b5BA48CafC49e761Dd658249AA969ED3);
        _fundAddress = address(0x6Ed37787FecBf669aAE0177774066461C793BBf0);
        _nodePoolAddress = address(0xe63916d0A84E7147eB2e6c3C9EB667F87774539b);
        _lotteryPool[0].price = 10 ** 17;
        _lotteryPool[0].max = 2;
        _lotteryPool[1].price = 10 ** 17;
        _lotteryPool[1].max = 3;
        _lotteryPool[2].price = 5 * 10 ** 17;
        _lotteryPool[2].max = 2;
        _lotteryPool[3].price = 5 * 10 ** 17;
        _lotteryPool[3].max = 3;
        _lotteryPoolLength = 4;
        _nodePoolLength = 3;
        _dividendRate[0] = 1000;
        _dividendRate[1] = 3000;
        _dividendRate[2] = 6000;
    }
}