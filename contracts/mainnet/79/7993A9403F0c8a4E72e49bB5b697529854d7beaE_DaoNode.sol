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

    address public immutable tokenAddress;
    uint public revokeNodeDuration = 10 days;
    uint public revokeVoteDuration = 10 days;
    bool public isVote = true;
    bool public isBonus;
    uint public bonusDay = 30;
    uint public constant bonusEpoch = 1 days;
    mapping(address => VoteToken) public voteToken;

    mapping(address => uint) public totalUnstakeAmount;
    mapping(address => mapping(address => uint)) public userUnstakeAmount;
    mapping(address => uint) public userUnstakeAt;

    uint public roundId;
    uint public nodesCount;
    mapping(uint => BonusNode) public roundInfo;
    mapping(uint => address) public nodeIdAddr;
    mapping(address => NodeInfo) public nodeInfo;
    mapping(address => UserInfo) public userInfo;
    mapping(address => mapping(address => uint)) public userStakeToken;

    uint public totalVote;
    uint public totalReward;
    uint public totalUsedReward;
    uint public lastBonusEpoch;
    uint public accPerShare;
    uint public totalNodeReward;
    uint public totalUsedNodeReward;

    struct VoteToken {
        uint rate;
        bool status;
        uint applyNode;
    }

    struct NodeInfo {
        uint id;
        bool status;
        uint stakedAmount;
        address stakedToken;
        address admin;
        uint totalReward;
        uint pendingReward;
        uint totalVote;
        uint totalVoter;
        uint applyNodeAt;
        uint unstakeAmount;
        uint unstakeAt;
    }

    struct UserInfo {
        address node;
        uint stakedOf;
        uint voteOf;
        uint rewardOf;
        uint lastVoteAt;
        uint lastRewardAt;
        uint userReward;
    }

    struct BonusNode {
        uint roudId;
        uint endTime;
        uint totalNode;
        uint totalVote;
    }

    event EmitApplyNode(address indexed nodeAddr);
    event EmitRevokeNode(address indexed nodeAddr);
    event EmitBonusNode(uint indexed round, uint time, uint _node, uint _vote);

    event EmitNodeVote(
        address indexed account,
        address indexed nodeAddr,
        uint voteAmount
    );

    event EmitRevokeVote(
        address indexed account,
        address indexed nodeAddr,
        uint voteAmount
    );

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
            admin: msg.sender,
            totalReward: 0,
            pendingReward: 0,
            totalVote: 0,
            totalVoter: 0,
            unstakeAmount: 0,
            unstakeAt: 0
        });
        nodesCount += 1;
        nodeIdAddr[id] = msg.sender;
        emit EmitApplyNode(msg.sender);
    }

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

        _bonusReward();
        uint pending;
        if (user.voteOf > 0) {
            pending = ((user.voteOf * accPerShare) / 1e12) - user.rewardOf;
        } else {
            nodeInfo[node].totalVoter += 1;
        }

        TransferHelper.safeTransferFrom(
            _token,
            msg.sender,
            address(this),
            amount
        );

        uint _vote = (amount * voteToken[_token].rate) / 100;
        nodeInfo[node].totalVote += _vote;
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
        _bonusReward();
        UserInfo storage user = userInfo[msg.sender];
        uint amount = userStakeToken[msg.sender][_token];
        require(amount > 0, "amount is zero error");

        uint _vote = (amount * voteToken[_token].rate) / 100;
        userStakeToken[msg.sender][_token] -= amount;
        uint pending;
        if (user.voteOf > 0) {
            pending = ((user.voteOf * accPerShare) / 1e12) - user.rewardOf;
        }
        user.voteOf -= _vote;
        user.stakedOf -= amount;
        user.rewardOf = (user.voteOf * accPerShare) / 1e12;
        totalVote -= _vote;
        nodeInfo[user.node].totalVote -= _vote;

        if (user.voteOf == 0) {
            nodeInfo[user.node].totalVoter -= 1;
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
        _bonusReward();
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