// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

contract DaoNode {
    address public owner;
    address public operator;

    address public tokenAddress;
    uint public revokeNodeDuration = 3600; //10 days;
    uint public revokeVoteDuration = 1800; //10 days;
    bool public isVote = true; // 是否开启质押
    bool public isBonus; // 是否开启奖励
    uint public bonusDay = 30; //20 d
    uint public constant bonusEpoch = 1800; //1 days; // 奖励周期 86400
    mapping(address => VoteToken) public voteToken;

    mapping(address => uint) public totalUnstakeAmount;
    mapping(address => mapping(address => uint)) public userUnstakeAmount;
    mapping(address => uint) public userUnstakeAt;

    uint public roundId;
    uint public nodesCount;
    mapping(uint => BonusNode) public roundInfo; //节点详情
    mapping(uint => address) public nodeIdAddr; //节点详情
    mapping(address => NodeInfo) public nodeInfo; //节点详情
    mapping(address => UserInfo) public userInfo; //节点选民
    mapping(address => mapping(address => uint)) public userStakeToken; //节点选民

    uint public totalVote;
    uint public totalReward; //总奖励
    uint public totalUsedReward; //总分红奖励
    uint public lastBonusEpoch; //上一次分红时间
    uint public accPerShare;
    uint public totalNodeReward; //总奖励
    uint public totalUsedNodeReward; //总分红奖励

    struct VoteToken {
        uint rate;
        bool status;
        uint applyNode;
    }

    // 每个池的信息。
    struct NodeInfo {
        uint id;
        bool status;
        uint stakedAmount;
        address stakedToken;
        address admin; // 管理员
        uint totalReward; //总分红
        uint pendingReward; // 总选民
        uint totalVote; // 分配给此池的分配点数。
        uint totalVoter; // 总选民
        uint applyNodeAt;
        uint unstakeAmount;
        uint unstakeAt;
    }

    // 每个用户的信息。
    struct UserInfo {
        address node;
        uint stakedOf;
        uint voteOf; // 用户提供了多少 LP 代币。
        uint rewardOf; // 用户已经获取的奖励
        uint lastVoteAt; //最后质押时间
        uint lastRewardAt; //最后领奖时间
        uint userReward; //用户奖励
    }

    struct BonusNode {
        uint roudId;
        uint endTime;
        uint totalNode;
        uint totalVote;
    }

    // 申请节点
    event EmitApplyNode(address indexed nodeAddr);
    event EmitRevokeNode(address indexed nodeAddr);
    event EmitBonusNode(uint indexed round, uint time, uint _node, uint _vote);
    // 投票
    event EmitNodeVote(
        address indexed account,
        address indexed nodeAddr,
        uint voteAmount
    );
    //撤销投票
    event EmitRevokeVote(
        address indexed account,
        address indexed nodeAddr,
        uint voteAmount
    );
    // 领取奖励事件
    event EmitReward(
        address indexed account,
        address indexed nodeAddr,
        uint amount
    );
    event WithdrawUnstaked(
        address indexed to,
        address indexed lpToken,
        uint amount
    );

    constructor(address _token) {
        owner = msg.sender;
        operator = owner;
        tokenAddress = _token;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    modifier onlyOperator() {
        require(operator == msg.sender, "caller is not the operator");
        _;
    }

    function setOwner(address _value) external onlyOwner {
        owner = _value;
    }

    function setOperator(address _value) external onlyOwner {
        operator = _value;
    }

    function setRevokeNodeDuration(uint _value) external onlyOwner {
        revokeNodeDuration = _value;
    }

    function setRevokeVoteDuration(uint _value) external onlyOwner {
        revokeVoteDuration = _value;
    }

    function setVoteTokenRate(
        address _token,
        uint _rate,
        uint _applyNodeRequired
    ) external onlyOwner {
        require(voteToken[_token].rate == 0, "Do not support the change");
        require(_rate > 0, "rate is zero error");
        voteToken[_token].rate = _rate;
        voteToken[_token].status = true;
        voteToken[_token].applyNode = _applyNodeRequired;
    }

    function setApplyNodeRequired(
        address _token,
        uint _applyNode
    ) external onlyOwner {
        require(voteToken[_token].rate > 0, "There is no init");
        voteToken[_token].applyNode = _applyNode;
    }

    function setVoteTokenStatus(
        address _token,
        bool _value
    ) external onlyOwner {
        require(voteToken[_token].rate > 0, "There is no init");
        voteToken[_token].status = _value;
    }

    function setBonusDay(uint day) external onlyOwner {
        bonusDay = day;
    }

    function setIsBonus(bool value) external onlyOwner {
        isBonus = value;
    }

    function setIsVote(bool _value) external onlyOwner {
        isVote = _value;
    }

    function withdrawToken(
        address token,
        address to,
        uint amount
    ) external onlyOwner {
        TransferHelper.safeTransfer(token, to, amount);
    }

    //存入奖励
    function depositNodeReward(uint amount_) external {
        TransferHelper.safeTransferFrom(
            tokenAddress,
            msg.sender,
            address(this),
            amount_
        );

        totalNodeReward += amount_;
    }

    function bonusNodeReward(
        address[] memory nodes,
        uint[] memory amounts
    ) external onlyOperator {
        uint usedReward;
        for (uint i = 0; i < nodes.length; ++i) {
            require(nodeInfo[nodes[i]].status, "Node status error");
            nodeInfo[nodes[i]].pendingReward += amounts[i];
            usedReward += amounts[i];
        }
        totalUsedNodeReward += usedReward;
        require(
            totalNodeReward >= totalUsedNodeReward,
            "reward overflow error"
        );
        uint id = roundId;
        roundId += 1;
        roundInfo[id] = BonusNode({
            roudId: id,
            endTime: block.timestamp,
            totalNode: nodesCount,
            totalVote: totalVote
        });
        emit EmitBonusNode(id, block.timestamp, nodesCount, totalVote);
    }

    //存入奖励
    function depositReward(uint amount_) external {
        TransferHelper.safeTransferFrom(
            tokenAddress,
            msg.sender,
            address(this),
            amount_
        );

        totalReward += amount_;
    }

    function getPendingReward() public view returns (uint) {
        return (totalReward - totalUsedReward) / bonusDay;
    }

    function rewardAmount(address _account) external view returns (uint) {
        uint pending;
        UserInfo memory _user = userInfo[_account];
        if (_user.voteOf > 0) {
            uint _accPerShare = accPerShare;
            uint _epoch_day = block.timestamp / bonusEpoch;
            if (isBonus && _epoch_day > lastBonusEpoch) {
                uint _reward = getPendingReward();
                _accPerShare += (_reward * 1e12) / totalVote;
            }
            pending = ((_user.voteOf * _accPerShare) / 1e12) - _user.rewardOf;
        }

        return pending;
    }

    function getNodeInfo(uint id) external view returns (NodeInfo memory node) {
        return nodeInfo[nodeIdAddr[id]];
    }

    // 更新分红奖励
    function bonusReward() external {
        require(isBonus, "Bonus is not enabled");
        uint _epoch_day = block.timestamp / bonusEpoch;
        require(_epoch_day > lastBonusEpoch, "Error: lastBonusEpoch");
        require(totalVote > 0, "No vote");

        _bonusReward();
    }

    function _bonusReward() private {
        if (isBonus && totalVote > 0) {
            uint _epoch_day = block.timestamp / bonusEpoch;
            if (_epoch_day > lastBonusEpoch) {
                lastBonusEpoch = _epoch_day;
                uint _reward = getPendingReward();
                accPerShare += (_reward * 1e12) / totalVote;
                totalUsedReward += _reward;
            }
        }
    }

    //申请节点
    function applyNode(address _token) external {
        require(isVote, "vote is not enabled");
        require(nodeInfo[msg.sender].admin == address(0), "repeat apply error");
        require(
            voteToken[_token].status && voteToken[_token].rate > 0,
            "Token is not supported"
        );
        TransferHelper.safeTransferFrom(
            _token,
            msg.sender,
            address(this),
            voteToken[_token].applyNode
        );

        uint id = nodesCount;
        nodeInfo[msg.sender] = NodeInfo({
            id: id,
            status: true,
            applyNodeAt: block.timestamp,
            stakedToken: _token,
            stakedAmount: voteToken[_token].applyNode,
            admin: msg.sender, // 管理员
            totalReward: 0, //总分红
            pendingReward: 0, // 总选民
            totalVote: 0, // 分配给此池的分配点数。
            totalVoter: 0, // 总选民
            unstakeAmount: 0,
            unstakeAt: 0
        });
        nodesCount += 1;
        nodeIdAddr[id] = msg.sender;
        emit EmitApplyNode(msg.sender);
    }

    //撤销节点
    function revokeNode() external {
        require(nodeInfo[msg.sender].status, "Node status error");
        uint amount = nodeInfo[msg.sender].stakedAmount;
        nodeInfo[msg.sender].status = false;
        nodeInfo[msg.sender].unstakeAmount = amount;
        nodeInfo[msg.sender].unstakeAt = block.timestamp;
        totalUnstakeAmount[nodeInfo[msg.sender].stakedToken] += amount;

        emit EmitRevokeNode(msg.sender);
    }

    function revokeNodeWithdraw() external returns (bool) {
        address _token = nodeInfo[msg.sender].stakedToken;
        uint _amount = nodeInfo[msg.sender].unstakeAmount;
        require(_amount > 0, "The withdraw amount must be greater than zero");
        require(
            block.timestamp >
                nodeInfo[msg.sender].unstakeAt + revokeNodeDuration,
            "The time passed since the last unstake is less than revokeNodeDuration"
        );

        nodeInfo[msg.sender].unstakeAmount -= _amount;
        totalUnstakeAmount[_token] -= _amount;
        TransferHelper.safeTransfer(_token, msg.sender, _amount);

        emit WithdrawUnstaked(msg.sender, _token, _amount);
        return true;
    }

    // 投票
    function nodeVote(address node, address _token, uint amount) external {
        require(isVote, "vote is not enabled");
        require(nodeInfo[node].status, "Node status error");
        require(
            voteToken[_token].status && voteToken[_token].rate > 0,
            "Token is not supported"
        );
        require(amount > 0, "amount is zero error");
        require(nodeInfo[node].admin != msg.sender, "Can't vote for himself");
        UserInfo storage user = userInfo[msg.sender];
        require(
            user.node == node || user.node == address(0),
            "Not allowed to change the node"
        );

        _bonusReward(); //更新分红奖励
        uint pending;
        if (user.voteOf > 0) {
            // 领取之前的奖励
            pending = ((user.voteOf * accPerShare) / 1e12) - user.rewardOf;
        } else {
            nodeInfo[node].totalVoter += 1; // 总选民
        }

        TransferHelper.safeTransferFrom(
            _token,
            msg.sender,
            address(this),
            amount
        );

        uint _vote = (amount * voteToken[_token].rate) / 100;
        nodeInfo[node].totalVote += _vote; // 分配给此池的分配点数。
        user.node = node;
        user.voteOf += _vote;
        user.stakedOf += amount;
        user.rewardOf = (user.voteOf * accPerShare) / 1e12;
        totalVote += _vote;
        user.lastVoteAt = block.timestamp;
        userStakeToken[msg.sender][_token] += amount;
        _safeRewardTransfer(msg.sender, user.node, pending);

        emit EmitNodeVote(msg.sender, node, _vote);
    }

    function revokeVote(address _token) external {
        _bonusReward(); //更新分红奖励
        UserInfo storage user = userInfo[msg.sender];
        uint amount = userStakeToken[msg.sender][_token];
        require(amount > 0, "amount is zero error");

        uint _vote = (amount * voteToken[_token].rate) / 100;
        userStakeToken[msg.sender][_token] -= amount;
        uint pending;
        if (user.voteOf > 0) {
            // 领取之前的奖励
            pending = ((user.voteOf * accPerShare) / 1e12) - user.rewardOf;
        }
        user.voteOf -= _vote;
        user.stakedOf -= amount;
        user.rewardOf = (user.voteOf * accPerShare) / 1e12;
        totalVote -= _vote;
        nodeInfo[user.node].totalVote -= _vote;

        if (user.voteOf == 0) {
            nodeInfo[user.node].totalVoter -= 1; // 总选民
            if (!nodeInfo[user.node].status) {
                user.node = address(0);
            }
        }

        userUnstakeAmount[_token][msg.sender] += amount;
        userUnstakeAt[msg.sender] = block.timestamp;
        totalUnstakeAmount[_token] += amount;
        _safeRewardTransfer(msg.sender, user.node, pending);

        emit EmitRevokeVote(msg.sender, user.node, _vote);
    }

    function revokeVoteWithdraw(address _token) external returns (bool) {
        uint _amount = userUnstakeAmount[_token][msg.sender];
        require(_amount > 0, "The withdraw amount must be greater than zero");
        require(
            block.timestamp > userUnstakeAt[msg.sender] + revokeVoteDuration,
            "The time passed since the last unstake is less than revokeNodeDuration"
        );

        userUnstakeAmount[_token][msg.sender] -= _amount;
        totalUnstakeAmount[_token] -= _amount;
        TransferHelper.safeTransfer(_token, msg.sender, _amount);

        emit WithdrawUnstaked(msg.sender, _token, _amount);
        return true;
    }

    function takeReward() external {
        _bonusReward(); //更新分红奖励
        UserInfo storage user = userInfo[msg.sender];
        require(user.voteOf > 0, "voteOf is zero");
        uint rewardOf = (user.voteOf * accPerShare) / 1e12;
        uint pending = rewardOf - user.rewardOf;
        require(pending > 0, "Staking: no pending reward");
        user.rewardOf = rewardOf;
        _safeRewardTransfer(msg.sender, user.node, pending);
    }

    function takeNodeReward() external {
        NodeInfo storage node = nodeInfo[msg.sender];
        require(node.pendingReward > 0, "reward is zero");
        uint pending = node.pendingReward;
        node.pendingReward = 0;
        node.totalReward += pending;
        TransferHelper.safeTransfer(tokenAddress, msg.sender, pending);
    }

    function _safeRewardTransfer(
        address _user,
        address _node,
        uint _pending
    ) internal {
        if (_pending > 0) {
            TransferHelper.safeTransfer(tokenAddress, _user, _pending);
            userInfo[_user].userReward += _pending;
            userInfo[_user].lastRewardAt = block.timestamp;
            emit EmitReward(msg.sender, _node, _pending);
        }
    }
}