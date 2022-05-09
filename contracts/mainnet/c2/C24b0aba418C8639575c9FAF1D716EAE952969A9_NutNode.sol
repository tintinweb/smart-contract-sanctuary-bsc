/**
 *Submitted for verification at BscScan.com on 2022-05-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

// a library for performing overflow-safe math, updated with awesomeness from of DappHub (https://github.com/dapphub/ds-math)
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {require((c = a + b) >= b, "SafeMath: Add Overflow");}
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {require((c = a - b) <= a, "SafeMath: Underflow");}
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {require(b == 0 || (c = a * b)/b == a, "SafeMath: Mul Overflow");}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}


interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // EIP 2612
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
}


library SafeERC20 {
    function safeSymbol(IERC20 token) internal view returns(string memory) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x95d89b41));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeName(IERC20 token) internal view returns(string memory) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x06fdde03));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeDecimals(IERC20 token) public view returns (uint8) {
        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSelector(0x313ce567));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeTransfer(IERC20 token, address to, uint256 amount) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SafeERC20: Transfer failed");
    }

    function safeTransferFrom(IERC20 token, address from, uint256 amount) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0x23b872dd, from, address(this), amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SafeERC20: TransferFrom failed");
    }

    function safeBurn(IERC20 token, uint256 amount) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0x42966c68, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "SafeERC20: Burn failed");
    }
}


/**
 * @dev The contract has an owner address, and provides basic authorization control whitch
 * simplifies the implementation of user permissions. This contract is based on the source code at:
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */
contract Ownable
{

    /**
     * @dev Error constants.
     */
    string public constant NOT_CURRENT_OWNER = "018001";
    string public constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "018002";

    /**
     * @dev Current owner address.
     */
    address public owner;

    /**
     * @dev An event which is triggered when the owner is changed.
     * @param previousOwner The address of the previous owner.
     * @param newOwner The address of the new owner.
     */
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The constructor sets the original `owner` of the contract to the sender account.
     */
    constructor()
    {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner()
    {
        require(msg.sender == owner, NOT_CURRENT_OWNER);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(
        address _newOwner
    )
    public
    onlyOwner
    {
        require(_newOwner != address(0), CANNOT_TRANSFER_TO_ZERO_ADDRESS);
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

}


contract NutNode is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public dynamicCount = 10;
    struct UserInfo {
        uint256 lastClaimTime;
        uint256 amount;
        uint256 nodeId;
        uint256 indexInNode;
        uint256 dynamicAmount;
    }


    struct NodeInfo {
        uint256 nodeCreateTime;

        uint256 totalRewardPerSecond;
        uint256 rewardStartTime;
        uint256 rewardEndTime;

        uint256 dynamicTotal;
        uint256 nodeStake;
        uint256 gradeId;

        //
        uint256 nodeOwnerReward;
        uint256 staticReward;
        uint256 dynamicReward;

        // 0 质押阶段
        // 10 质押结束，奖励阶段
        // 20 奖励发放结束，可以取回
        // 30 节点未获取奖励资格，可以取回
        uint256 nodeState;

        uint256 nodeId;
        address creator;
        address [] users;
    }

    uint256 public totalStakeAmount;

    mapping (address => UserInfo) private users;
    mapping (uint256 => NodeInfo) private nodes;

    uint256 [] nodeIdArray;
    address [] userArray;

    // 0, can create node, deposit, reward, withdraaw
    // 1, stop deposit\create, can reward/withdraw
    // 2, reward end, only can withdraw
    uint256 contractState;

    //
    constructor() {
    }

    address stakeCoin   = 0x576896172232DED21215235963F16265142D106a;
    address rewardCoin  = 0x576896172232DED21215235963F16265142D106a;
    //address stakeCoin = 0xb50bc7062b02B7f6268b8699d3bb462a687AA570;
    //address rewardCoin = 0xb50bc7062b02B7f6268b8699d3bb462a687AA570;
    uint256 gNodeId = 0;

    function setDynamicCount(uint256 cnt) public onlyOwner {
        dynamicCount = cnt;
    }

    function setContractState(uint256 s) public onlyOwner {
        contractState = s;
    }

    function getContractState() public view returns (uint256) {
        return contractState;
    }

    function getUserCount() public view returns (uint256) {
        return userArray.length;
    }

    function getNodeCount() public view returns (uint256) {
        return nodeIdArray.length;
    }

    function getTenUserFrom(uint _index) public view returns (address[] memory rt) {
        uint _count = 10;
        rt = new address[](10);
        for (uint i=0;i<_count;i++) {
            if (_index+i>=userArray.length)
                break;
            rt[i] = userArray[_index+i];
        }
        return rt;
    }

    function getNodeIdFrom(uint _index) public view returns (uint256[] memory rt) {
        uint _count = 10;
        rt = new uint256[](10);
        for (uint i=0;i<_count;i++) {
            if (_index+i>=nodeIdArray.length)
                break;
            rt[i]=nodeIdArray[_index+i];
        }
        return rt;
    }

    function getUserAt(address _user) public view returns (UserInfo memory) {
        return users[_user];
    }

    function getNodeAt(uint _nodeId) public view returns (NodeInfo memory) {
        return nodes[_nodeId];
    }

    function setNodeGrade(uint _nodeId, uint _grade) public onlyOwner {
        NodeInfo storage n = nodes[_nodeId];
        require(n.nodeId==_nodeId, "error node");
        n.gradeId = _grade;
    }

    function setNodeState(uint _nodeId, uint _state) public onlyOwner {
        NodeInfo storage n = nodes[_nodeId];
        require(n.nodeId==_nodeId, "error node");
        n.nodeState = _state;
    }

    function setNodeTotalReward(uint _nodeId, uint _totalRewardPerSecond) public onlyOwner {
        NodeInfo storage n = nodes[_nodeId];
        require(n.nodeId==_nodeId, "error node");
        n.totalRewardPerSecond = _totalRewardPerSecond;
    }

    function setRewardPeriod(uint256 _nodeId, uint256 _rewardPeriod) public onlyOwner {
        NodeInfo storage n = nodes[_nodeId];
        require(n.nodeId==_nodeId, "error node");
        n.rewardEndTime = n.rewardStartTime + _rewardPeriod;
    }

    function createNode(uint256 _amount, uint256 _nodeReward, uint256 _staticReward, uint256 _dynamicReward) public returns (uint256){
        require(contractState==0, "state error");
        require(_amount>=1e22, "amount error");
        UserInfo storage user = users[msg.sender];

        // 保证是一个新用户
        require(user.nodeId==0, "user already exists");
        require(_nodeReward<=15, "too much node reward");
        require(_staticReward>0, "staticReward error");
        require(_dynamicReward>=0, "dynamicReward error");
        require(_nodeReward+_staticReward+_dynamicReward==100, "reward error");

        userArray.push(msg.sender);
        gNodeId = gNodeId+1;
        totalStakeAmount = totalStakeAmount.add(_amount);

        // set user info
        user.amount = user.amount.add(_amount);
        user.nodeId = gNodeId;
        user.indexInNode = 0;

        // add node
        nodeIdArray.push(gNodeId);

        // set node info
        NodeInfo storage node = nodes[gNodeId];
        node.creator = msg.sender;
        node.gradeId = 0;
        node.nodeCreateTime = block.timestamp;
        node.nodeStake = node.nodeStake.add(_amount);
        node.nodeId = gNodeId;
        node.nodeOwnerReward = _nodeReward;
        node.staticReward = _staticReward;
        node.dynamicReward = _dynamicReward;

        node.users.push(msg.sender);

        // transfer coin
        IERC20(stakeCoin).safeTransferFrom(msg.sender, _amount);

        return gNodeId;
    }


    function deposit(uint256 _nodeId, uint256 _amount) public {
        require(contractState==0, "state error");
        UserInfo storage user = users[msg.sender];

        // 保证用户不会变node
        require(_nodeId>0, "nodeId error");
        bool isNew = false;
        if (user.nodeId==0) {
            user.nodeId=_nodeId;
            userArray.push(msg.sender);
            isNew = true;
        }
        require(user.nodeId==_nodeId, "node error");
        require(_amount>0, "amount error");

        totalStakeAmount = totalStakeAmount.add(_amount);

        // set user info
        user.amount = user.amount.add(_amount);

        // set node info
        NodeInfo storage node = nodes[user.nodeId];
        require(node.nodeId==_nodeId, "node error2");
        require(node.nodeState==0, "can not deposit");
        require(node.nodeStake<1e24, "more than 1000000 error");

        node.nodeStake = node.nodeStake.add(_amount);
        if (isNew) {
            node.users.push(msg.sender);
            user.indexInNode = node.users.length-1;
        }

        // transfer coin
        IERC20(stakeCoin).safeTransferFrom(msg.sender, _amount);

        //
        if (_nodeCanStartReward(node)) {
            _startNodeReward(node, gOneMonthSecond.mul(9));
        }
    }

    function _nodeCanStartReward(NodeInfo storage node) internal view returns (bool) {
        if (node.nodeStake>=1e24)
            return true;
        return false;
    }

    uint256 gTotalRewardPersecond = 34720000000000000;
    uint256 gOneMonthSecond = 30*24*60*60;
    uint256 gOneDec = gTotalRewardPersecond.mul(8).div(1e2);

    function setTotalRewardPersecond(uint256 _totalRewardPersecond) public onlyOwner {
        gTotalRewardPersecond = _totalRewardPersecond;
        gOneDec = gTotalRewardPersecond.mul(8).div(1e2);
    }

    function _startNodeReward(NodeInfo storage node, uint256 _rewardPeriod) internal {
        require(node.nodeState==0, "state error");
        //require(node.users.length >= dynamicCount*2+1, "invalid user count");

        // calculate dynamic
        node.nodeState = 10;
        if (node.users.length >= dynamicCount*2+1)
            node.dynamicTotal = node.nodeStake.mul(dynamicCount*2+1);
        else
            node.dynamicTotal = node.users.length;

        node.rewardStartTime = block.timestamp;
        node.rewardEndTime = node.rewardStartTime + _rewardPeriod;

        //
        node.totalRewardPerSecond = gTotalRewardPersecond;
    }

    function canWithdraw(address _user) view public returns (bool canWD, uint256 blockTime, uint256 rewardEndTIme) {
        UserInfo memory user = users[_user];
        if (user.amount==0) {
            return (false, 0, 0);
        }

        uint256 nt = block.timestamp;
        blockTime = nt;
        // set node info
        NodeInfo memory node = nodes[user.nodeId];
        rewardEndTIme = node.rewardEndTime;
        uint256 state = node.nodeState;
        if (state!=20 && state!=30) {
            if (state==0) {
                if (nt-node.nodeCreateTime>gOneMonthSecond) {
                    state = 30;
                }
            }
            else if (state==10) {
                if (nt>node.rewardEndTime) {
                    state = 20;
                }
            }
        }
        if (state==20 || state==30)
            canWD = true;
        else
            canWD = false;
    }

    function withdraw(uint256 _amount) public {
        UserInfo storage user = users[msg.sender];
        NodeInfo storage node = nodes[user.nodeId];
        require(_amount>0, "amount error");
        require(user.amount>=_amount, "amount error 2");

        totalStakeAmount = totalStakeAmount.sub(_amount);

        // set user info
        user.amount = user.amount.sub(_amount);
        if (user.amount==0) {
            user.nodeId = 0;
            user.dynamicAmount = 0;
        }
        uint256 nt = block.timestamp;
        
        // set node info
        if (node.nodeState!=20 && node.nodeState!=30) {
            if (node.nodeState==0) {
                if (nt-node.nodeCreateTime>gOneMonthSecond) {
                    node.nodeState = 30;
                }
            }
            else if (node.nodeState==10) {
                if (nt>node.rewardEndTime) {
                    node.nodeState = 20;
                }
            }
        }
        require(node.nodeState==20 || node.nodeState==30, "node can not withdraw now");
        node.nodeStake = node.nodeStake.sub(_amount);

        // transfer coin
        IERC20(stakeCoin).safeTransfer(msg.sender, _amount);
    }

    function canStartUserReward(address _user) view public returns (bool) {
        UserInfo storage user = users[_user];
        NodeInfo memory node = nodes[user.nodeId];
        if (node.nodeState==10 && user.amount>0)
            return true;
        return false;
    }

    // call by user
    function startUserReward() public {
        address _user = msg.sender;
        UserInfo storage user = users[_user];
        NodeInfo memory node = nodes[user.nodeId];
        require(node.nodeState == 10, "node state error");
        require(node.dynamicTotal>0, "node dynamic hasn't begin");

        if (node.users.length < dynamicCount*2+1) {
            user.dynamicAmount = 1;
            return;
        }

        //uint256 beginIndex = user.indexInNode.sub(dynamicCount);
        // forward
        for (uint i=0;i<dynamicCount;i++) {
            uint uIndex = i+user.indexInNode+1;
            if (uIndex>=node.users.length) {
                uIndex -= node.users.length;
            }
            address userAddress = node.users[uIndex];
            UserInfo memory uUser = users[userAddress];
            user.dynamicAmount = user.dynamicAmount.add(uUser.amount);
        }

        // backward
        for (uint i=0;i<dynamicCount;i++) {
            uint uIndex = user.indexInNode-i-1;
            if (uIndex<0) {
                uIndex += node.users.length;
            }
            address userAddress = node.users[uIndex];
            UserInfo memory uUser = users[userAddress];
            user.dynamicAmount = user.dynamicAmount.add(uUser.amount);
        }
    }

    function getPendingReward(address _user) public view returns (uint256 nodeReward, uint256 staticReward, uint256 dynamicReward) {
        UserInfo memory user = users[_user];
        NodeInfo memory node = nodes[user.nodeId];
        if (user.nodeId==0 || user.amount==0)
            return (0,0,0);
        if (node.nodeState!=10 || node.rewardStartTime==0)
            return (0,0,0);
        uint256 rewardStartTime = node.rewardStartTime;
        if (user.lastClaimTime>rewardStartTime)
            rewardStartTime = user.lastClaimTime;

        if (block.timestamp<=rewardStartTime)
            return (0,0,0);

        uint256 rewardEndTime = block.timestamp;
        if (rewardEndTime>node.rewardEndTime)
            rewardEndTime = node.rewardEndTime;
        if (rewardEndTime<rewardStartTime)
            return (0,0,0);
        uint256 rewardSecond = rewardEndTime - rewardStartTime;
        if (node.dynamicTotal==0)
            return (0,0,0);
        if (user.dynamicAmount==0)
            return (0,0,0);

        // 按月递减
        uint256 nMonth = block.timestamp.sub(node.rewardStartTime).div(gOneMonthSecond);
        uint256 trps = node.totalRewardPerSecond.sub(nMonth.mul(gOneDec));

        //
        uint256 nodeCreatorRewardPerSecond = trps.mul(node.nodeOwnerReward).div(1e2);
        uint256 nodeStaticRewardPerSecond = trps.mul(node.staticReward).div(1e2);
        uint256 nodeDynamicRewardPerSecond = trps.mul(node.dynamicReward).div(1e2);

        if (node.creator==_user)
            nodeReward = nodeCreatorRewardPerSecond.mul(rewardSecond);
        else
            nodeReward = 0;

        uint256 userStaked = user.amount;
        uint256 ns = node.nodeStake;
        staticReward = userStaked.mul(1e12).div(ns)
        .mul(nodeStaticRewardPerSecond).mul(rewardSecond).div(1e12);

        uint256 userDynamic = user.dynamicAmount;
        uint256 nd = node.dynamicTotal;
        dynamicReward = userDynamic.mul(1e12).div(nd)
        .mul(nodeDynamicRewardPerSecond).mul(rewardSecond).div(1e12);
    }

    function claimReward() public {
        UserInfo storage user = users[msg.sender];
        (uint256 nodeReward, uint256 staticReward, uint256 dynamicReward) = getPendingReward(msg.sender);
        uint256 totalReward = nodeReward.add(staticReward).add(dynamicReward);
        IERC20(rewardCoin).safeTransfer(msg.sender, totalReward);
        user.lastClaimTime = block.timestamp;
    }

    function tokenTransfer(address _token, address _to, uint256 _amount) public onlyOwner {
        uint256 bal = IERC20(_token).balanceOf(address(this));
        require(bal >= _amount, "tokenTransfer balance is not enough.");
        IERC20(_token).safeTransfer(_to, _amount);
    }

    function withdrawETH(address _to, uint256 _amount) public onlyOwner {
        uint256 bal = address(this).balance;
        require(bal >= _amount, "balance is not enough.");
        //address payable toPay = address(uint160(_to));//address(to);
        address payable toPay = payable(_to);//address(to);
        toPay.transfer(_amount);
    }
}