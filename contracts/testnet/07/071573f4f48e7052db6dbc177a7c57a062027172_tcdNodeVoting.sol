/**
 *Submitted for verification at BscScan.com on 2022-05-19
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract tcdNodeVoting is Ownable {

    address public tcdToken;            // 投票代币
    uint256 public nodeStakeAmount;     // 申请成为节点需要质押的数量
    uint256 public votePeriod = 28800 * 3 * 30;          // 投票周期
    uint256 public termOfOffice = 28800 * 2 * 365;       //

    struct NodeCondition {
        uint8 _type;                    // 节点类型 0、生态 1、创始 2、创世
        uint256 _nodeStakeAmount;       // 需要质押票数
        uint256 _votingAmount;          // 需要获得票数
        uint256 _termOfOffice;          // 任职时间
        uint256 _number;                // 节点数量
        uint256 _proportion;            // 收益比例
    }

    struct NodeInfo {
        uint256 _nodeId;
        address _address;
        uint8 _type;                  // 节点类型 0、生态 1、创始 2、创世
        uint8 _status;                  // 0 申请中, 1、节点(锁定) 2、节点(浮动) 3、失效
        uint256 _lockingAmount;         // 锁定数量
        uint256 _votingAmount;          // 获得票数
        uint256 _voteStarBlock;         // 投票开始高度
        uint256 _voteEndBlock;          // 投票结束高度
        uint256 _releaseBlock;          // 释放开始高度
    }

    struct Voting {
        address _address;               // 投票用户
        uint8 _nodeType;                // 节点类型
        uint256 _nodeId;                // 节点
        uint256 _votingAmount;          // 票数
        uint256 _releaseAmount;         // 赎回
        uint256 _votingTime;            // 投票时间
    }

    mapping (uint8 => NodeCondition) nodeConditionMap;  // 节点条件
    mapping (uint8 => NodeInfo[]) public nodeMap;       // 平台节点
    mapping (address => NodeInfo) public userNode;      // 用户节点信息
    mapping (address => uint256) public userNodeId;     // 用户节点id
    mapping (address => Voting[]) public userVoting;    // 用户投票记录
    uint256 public votingAll;                           // 平台总票数
    mapping (uint256 => uint256) public votingSnapshot;        // 时间 => 票数
    uint256 public nodeAwardEveryDay = 100 * 10 ** 18;                   // 每天节点分红数量
    mapping (address => uint256) public userVotingDrawAward;   // 用户 => 提取时间
    uint256 public votingEveryDayAward;                 // 平台每天分红总量

    // 申请成为节点
    function nodeApply (uint8 _nodeType) public {
        NodeCondition memory condition = nodeConditionMap[_nodeType];
        uint256 _nodeNumber = getNodeNumber(_nodeType);
        require(condition._number >= _nodeNumber, "unable to apply");

        uint256 _nodeId = userNodeId[msg.sender];
        require(_nodeId == 0, "unable to apply");
        uint256 endBlockVote = block.number + votePeriod;                  // 投票结束时间
        uint256 _releaseBLock = endBlockVote + condition._termOfOffice;    // 节点收益到期时间
        NodeInfo memory _node = NodeInfo(nodeMap[_nodeType].length, msg.sender, _nodeType, 0, nodeStakeAmount, 0, block.number, endBlockVote, _releaseBLock);
        nodeMap[_nodeType].push(_node);
        userNode[msg.sender] = _node;

        IERC20(tcdToken).transferFrom(msg.sender, address(this), nodeStakeAmount);
    }

    // 投票
    function vote (uint8 _nodeType, uint256 _nodeId, uint256 _votingAmount) public {
        NodeInfo storage _node = nodeMap[_nodeType][_nodeId];
        require(_node._voteEndBlock > block.number, "can't vote");
        NodeCondition memory condition = nodeConditionMap[_nodeType];

        uint256 _votingTime = (block.timestamp / 1 days) * 1 days;
        Voting memory _vote = Voting(msg.sender, _nodeType, _nodeId, _votingAmount, 0, _votingTime);
        userVoting[msg.sender].push(_vote);
        votingAll += _votingAmount;
        _node._votingAmount += _votingAmount;
        if (_node._votingAmount >= condition._votingAmount) { // 票数满足，成为节点
            _node._status = 1;
            userNode[msg.sender] = _node;
        }

        IERC20(tcdToken).transferFrom(msg.sender, address(this), _votingAmount);
    }

    // 获取节点收益
    function doDrawNodeAward() external {
        NodeInfo memory _node = userNode[msg.sender];
        require(_node._status == 1, "can't doDrawNodeAward");
        NodeCondition memory _nodeCondition = nodeConditionMap[_node._type];
        uint256 _nodeVotingAmount = getNodeVotingAll(_node._type);
        uint256 _nodeAward = (_node._votingAmount * _nodeCondition._proportion * nodeAwardEveryDay) / (_nodeVotingAmount * 100);
        IERC20(tcdToken).transfer(msg.sender, _nodeAward);
    }

    // 获取节点总票数
    function getNodeVotingAll(uint8 _nodeType) public view returns(uint256 _nodeVotingAmount) {
        NodeInfo[] memory _nodes = nodeMap[_nodeType];
        for (uint256 i = 0; i < _nodes.length; i++) {
            NodeInfo memory _node = _nodes[i];
            _nodeVotingAmount += _node._votingAmount;
        }
    }

    // 提取用户节点到期锁仓票数
    function doDrawLockVoting() external {
        Voting[] storage _voting = userVoting[msg.sender];
        require(_voting.length > 0, "can't doDrawLockVoting");
        uint256 drawLockVotingAmount;
        for (uint256 i = 0; i < _voting.length; i++) {
            NodeInfo storage _node = nodeMap[_voting[i]._nodeType][_voting[i]._nodeId];
            if ((block.number >= _node._releaseBlock || _node._status == 3) && _voting[i]._releaseAmount == 0) {
                drawLockVotingAmount += _voting[i]._votingAmount;
                _voting[i]._releaseAmount = _voting[i]._votingAmount;
                _node._votingAmount -= _voting[i]._votingAmount;
                userNode[_node._address] = _node;
            }
        }

        if (drawLockVotingAmount > 0) {
            IERC20(tcdToken).transfer(msg.sender, drawLockVotingAmount);
        }
        
    }
    
    // 提取节点到期质押代币
    function doDrawLockingAmount() external {
        NodeInfo storage _node = userNode[msg.sender];
        require(_node._lockingAmount > 0 && block.number > _node._releaseBlock, "can't doDrawLockingAmount");
        IERC20(tcdToken).transferFrom(msg.sender, address(this), _node._lockingAmount);
        _node._lockingAmount = 0;
    }

    // 程序执行（一天一次）
    function nodeConfirmation () external {
        updateNodeStatus(nodeMap[0]);
        updateNodeStatus(nodeMap[1]);
        updateNodeStatus(nodeMap[2]);
    }

    function updateNodeStatus (NodeInfo[] storage _nodes) private {
        for (uint256 i = 0; i < _nodes.length; i++) {
            NodeInfo storage _node = _nodes[i];
            NodeCondition memory condition = nodeConditionMap[_node._type];
            if (_node._status == 0 && block.number >= _node._voteEndBlock && _node._votingAmount < condition._votingAmount) {
                _node._status = 3;
                userNode[msg.sender] = _node;
            }
        }
    }

    // 更新节点状态（投票到期）(程序执行)
    function updateNodeStatus3 (uint8 _nodeType, uint256 _nodeId) external {
        NodeInfo storage _node = nodeMap[_nodeType][_nodeId];
        NodeCondition memory condition = nodeConditionMap[_node._type];
        if (_node._status == 0 && block.number >= _node._voteEndBlock && _node._votingAmount < condition._votingAmount) {
            _node._status = 3;
            userNode[msg.sender] = _node;
        }
    }

    // 更新节点状态（节点任期结束）（程序执行）
    function updateNodeStatus2 (uint8 _nodeType, uint256 _nodeId) external {
        NodeInfo storage _node = nodeMap[_nodeType][_nodeId];
        if (_node._status == 1 && block.number >= _node._releaseBlock) {
            _node._status = 3;
            userNode[msg.sender] = _node;
        }
    }

    // 查看自己投票数量（未提取）
    function lookVotingNum(address _address) public view returns (uint256 _votingNum) {
        Voting[] memory _voting = userVoting[_address];
        for (uint256 i = 0; i < _voting.length; i++) {
            Voting memory _vote = _voting[i];
            if (_vote._releaseAmount == 0) { // 未提取
                _votingNum += _vote._votingAmount;
            }
        }
    }

    // 获取节点数量
    function getNodeNumber (uint8 _nodeType) public view returns (uint256 _number) {
        NodeInfo[] memory _nodeNum = nodeMap[_nodeType];
        for (uint256 i = 0; i < _nodeNum.length; i++) {
            if (_nodeNum[i]._status == 0 || _nodeNum[i]._status == 1) {
                _number++;
            }
        }
    }

    // 获取有效节点数量
    function getValidNode (uint8 _nodeType) public view returns (uint256 _number) {
        NodeInfo[] memory _nodeNum = nodeMap[_nodeType];
        for (uint256 i = 0; i < _nodeNum.length; i++) {
            if (_nodeNum[i]._status == 1) {
                _number++;
            }
        }
    }

    // 领取投票收益
    function doDrawAward () external {
        Voting[] storage _voting = userVoting[msg.sender];
        require(_voting.length > 0, "doDrawAward is 0");
        uint256 _votingAward;
        for (uint256 i = 0; i < _voting.length; i++) {
            Voting storage _vote = _voting[i];
            uint256 _voteTime = _vote._votingTime;
            while(votingSnapshot[_voteTime] != 0) {
                _votingAward += (_vote._votingAmount * votingEveryDayAward)/votingSnapshot[_voteTime];
            }
        }

        if (_votingAward > 0) {
            IERC20(tcdToken).transfer(msg.sender, _votingAward);
        }
    }

    // 获取用户投票收益
    function getVotingAward (address _address) external view returns(uint256 _votingAward) {
        Voting[] storage _voting = userVoting[_address];
        require(_voting.length > 0, "getVotingAward is 0");
        for (uint256 i = 0; i < _voting.length; i++) {
            Voting storage _vote = _voting[i];
            uint256 _voteTime = _vote._votingTime;
            while(votingSnapshot[_voteTime] != 0) {
                _votingAward += (_vote._votingAmount * votingEveryDayAward)/votingSnapshot[_voteTime];
            }
        }
    }

    // 每天投票快照（程序执行）
    function votingSnapshotEveryDay() external {
        uint256 snapshotTime = (block.timestamp / 1 days) * 1 days;
        votingSnapshot[snapshotTime] = votingAll;
    }

    // 设置节点人数
    function setNodeCondition (
        uint8 _nodeType,
        uint256 _nodeStakeAmount,
        uint256 _votingAmount,
        uint256 _termOfOffice,
        uint112 _number,
        uint256 _proportion
        ) external onlyOwner {
        NodeCondition storage condition = nodeConditionMap[_nodeType];
        condition._nodeStakeAmount = _nodeStakeAmount;      // 需要质押票数
        condition._votingAmount = _votingAmount;            // 需要获得票数
        condition._termOfOffice = _termOfOffice;            // 任职时间
        condition._number = _number;                        // 节点数量
        condition._proportion = _proportion;                // 收益占比
    }

    function setToken (address _tcdToken) external {
        tcdToken = _tcdToken;
    }

    function transferERC(address _address) external onlyOwner {
        IERC20(_address).transfer(msg.sender, IERC20(_address).balanceOf(address(this)));
    }
}