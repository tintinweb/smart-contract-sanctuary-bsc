/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is TKNaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key)
        public
        view
        returns (int256)
    {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint256 index)
        public
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint256 val
    ) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

interface INODERewardManagement {
    struct NodeEntity {uint8 nodeType; uint256 creationTime; uint256 lastClaimTime; uint256 rewardAvailable;}
    struct NodeType { uint256 maxNode; uint256 nodePrice; uint256 rewardPerNode; uint256 claimTime; uint256 maxWalletPercentSellNum; uint256 maxWalletPercentSellDen;}
    function setToken (address token_) external;
    function _addNodeType(uint8 nodeType, uint256 maxNode, uint256 nodePrice, uint256 claimTime, uint256 rewardPerNode, uint256 maxWalletPercentSellNum, uint256 maxWalletPercentSellDen) external;
    function _getMaxSell(address account, uint256 balance) external view returns (uint256);
    function _getTypes() external view returns (uint8[] memory);
    function _getMaxSellByNodeType(uint8 nodeType, uint256 balance) external view returns (uint256);
    function _getNodePrice(uint8 nodeType) external view returns (uint256);
    function _getRewardPerNode(uint8 nodeType) external view returns (uint256);
    function _getClaimTime(uint8 nodeType) external view returns (uint256);
    function _getMaxNode(uint8 nodeType) external view returns (uint256);
    function _getMaxWalletPercentSellNum(uint8 nodeType) external view returns (uint256);
    function _getMaxWalletPercentSellDen(uint8 nodeType) external view returns (uint256);
    function _enableNodeType(uint8 nodeType, bool value) external;
    function createNode(address account, uint8 nodeType) external;
    function _cashoutAllNodesReward(address account) external returns (uint256);
    function _getRewardAmountOf(address account) external view returns (uint256);
    function _changeAutoDistri(bool newMode, uint256 newGasDistri) external;
    function _getDefaultMaxWalletPercentSell() external view returns (uint256[2] memory);
    function _changeDefaultMaxWalletPercentSell(uint256 newDefaultMaxWalletPercentSellNum, uint256 newDefaultMaxWalletPercentSellDen) external;
    function _getNodeTypeNumberOf(address account, uint8 nodeType) external view returns (uint256);
    function _getNodeNumberOf(address account) external view returns (uint256);
    function _isNodeOwner(address account) external view returns (bool);
    function _distributeRewards() external returns ( uint256, uint256, uint256);
}

contract NODERewardManagement is INODERewardManagement {
    using SafeMath for uint256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private nodeOwners;
    mapping(address => NodeEntity[]) private _nodesOfUser;

    mapping(uint8 => NodeType) public nodeTypes;
    mapping(uint8 => bool) public isNodeTypeAvailable;
    mapping(address => mapping(uint256 => uint256)) public nodeCounts;

    uint8[] types;

    bool public autoDistri = true;
    bool public distribution;

    address public gateKeeper;
    address public token;

    uint256 public gasForDistribution = 300000;
    uint256 public lastDistributionCount;
    uint256 public lastIndexProcessed;

    uint256 public totalNodesCreated;
    uint256 public totalRewardStaked;

    uint256 private defaultMaxWalletPercentSellNum = 5;
    uint256 private defaultMaxWalletPercentSellDen = 100;

    constructor() {gateKeeper = msg.sender;}

    function setToken (address token_) external override {
        require(msg.sender == token || msg.sender == gateKeeper);
        token = token_;
    }

    function _addNodeType(uint8 nodeType, uint256 maxNode, uint256 nodePrice, uint256 claimTime, uint256 rewardPerNode, uint256 maxWalletPercentSellNum, uint256 maxWalletPercentSellDen) external override
    {
        require(msg.sender == token || msg.sender == gateKeeper);
        nodeTypes[nodeType] = NodeType({
                nodePrice: nodePrice,
                maxNode: maxNode,
                rewardPerNode: rewardPerNode,
                claimTime: claimTime,
                maxWalletPercentSellNum: maxWalletPercentSellNum,
                maxWalletPercentSellDen: maxWalletPercentSellDen
            });
        types.push(nodeType);
        isNodeTypeAvailable[nodeType] = true;
    }

    function _getMaxSell(address account, uint256 balance) external view override returns (uint256) 
    {
        uint256 maxSell = balance * defaultMaxWalletPercentSellNum / defaultMaxWalletPercentSellDen;
        uint8 localNodeType;

        for (uint256 i; i < types.length; i++){
            localNodeType = types[i];
            if (nodeCounts[account][localNodeType] < nodeTypes[localNodeType].maxNode){
                maxSell += nodeCounts[account][localNodeType] * getMaxSellByNodeType(localNodeType, balance);
            }
            else{
                maxSell += nodeTypes[localNodeType].maxNode * getMaxSellByNodeType(localNodeType, balance);
            }
        }

        return maxSell;

    }

    function _getTypes() external view override returns (uint8[] memory)
    {
        return types;
    }

    function getMaxSellByNodeType(uint8 nodeType, uint256 balance) private view returns (uint256) 
    {
        return balance * nodeTypes[nodeType].maxWalletPercentSellNum / nodeTypes[nodeType].maxWalletPercentSellDen;
    }

    function _getMaxSellByNodeType(uint8 nodeType, uint256 balance) external view override returns (uint256) 
    {
        return getMaxSellByNodeType(nodeType, balance);
    }

    function _getNodePrice(uint8 nodeType) external view override returns (uint256) 
    {
        return nodeTypes[nodeType].nodePrice;
    }

    function _getRewardPerNode(uint8 nodeType) external view override returns (uint256) 
    {
        return nodeTypes[nodeType].rewardPerNode;
    }

    function _getClaimTime(uint8 nodeType) external view override returns (uint256) 
    {
        return nodeTypes[nodeType].claimTime;
    }

    function _getMaxNode(uint8 nodeType) external view override returns (uint256) 
    {
        return nodeTypes[nodeType].maxNode;
    }

    function _getMaxWalletPercentSellNum(uint8 nodeType) external view override returns (uint256) 
    {
        return nodeTypes[nodeType].maxWalletPercentSellNum;
    }

    function _getMaxWalletPercentSellDen(uint8 nodeType) external view override returns (uint256) 
    {
        return nodeTypes[nodeType].maxWalletPercentSellDen;
    }

    function _enableNodeType(uint8 nodeType, bool value) external override
    {
        require(msg.sender == token || msg.sender == gateKeeper);
        isNodeTypeAvailable[nodeType] = value;
    }

    function distributeRewards(uint256 gas) private returns (uint256, uint256, uint256)
    {
        distribution = true;
        uint256 numberOfnodeOwners = nodeOwners.keys.length;
        require(numberOfnodeOwners > 0);
        if (numberOfnodeOwners == 0) {
            return (0, 0, lastIndexProcessed);
        }

        uint256 gasUsed;
        uint256 gasLeft = gasleft();
        uint256 newGasLeft;
        uint256 localLastIndex = lastIndexProcessed;
        uint256 iterations;
        uint256 newClaimTime = block.timestamp;
        uint256 nodesCount;
        uint256 claims;
        NodeEntity[] storage nodes;
        NodeEntity storage _node;

        while (gasUsed < gas && iterations < numberOfnodeOwners) {
            localLastIndex++;
            if (localLastIndex >= nodeOwners.keys.length) {
                localLastIndex = 0;
            }
            nodes = _nodesOfUser[nodeOwners.keys[localLastIndex]];
            nodesCount = nodes.length;
            for (uint256 i; i < nodesCount; i++) {
                _node = nodes[i];
                if (claimable(_node)) {
                    _node.rewardAvailable += nodeTypes[_node.nodeType].rewardPerNode;
                    _node.lastClaimTime = newClaimTime;
                    totalRewardStaked += nodeTypes[_node.nodeType].rewardPerNode;
                    claims++;
                }
            }
            iterations++;

            newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }
        lastIndexProcessed = localLastIndex;
        distribution = false;
        return (iterations, claims, lastIndexProcessed);
    }

    function createNode(address account, uint8 nodeType) external override 
    {
        require(msg.sender == token || msg.sender == gateKeeper);
        require(
            isNodeTypeAvailable[nodeType]);
        //require(
        //    nodeCounts[account][nodeType] < nodeTypes[nodeType].maxNode,
        //    "CREATE NODE: Max node reached for this type"
        //);

        _nodesOfUser[account].push(
            NodeEntity({
                nodeType: nodeType,
                creationTime: block.timestamp,
                lastClaimTime: block.timestamp,
                rewardAvailable: nodeTypes[nodeType].rewardPerNode
            })
        );
        nodeCounts[account][nodeType] += 1;
        nodeOwners.set(account, _nodesOfUser[account].length);
        totalNodesCreated++;
        if (autoDistri && !distribution) {
            distributeRewards(gasForDistribution);
        }
    }

    function _cashoutAllNodesReward(address account) external override returns (uint256)
    {
        require(msg.sender == token || msg.sender == gateKeeper);
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        require(nodesCount > 0);
        NodeEntity storage _node;
        uint256 rewardsTotal = 0;
        for (uint256 i = 0; i < nodes.length; i++) {
            _node = nodes[i];
            rewardsTotal += _node.rewardAvailable;
            _node.rewardAvailable = 0;
        }
        return rewardsTotal;
    }

    function claimable(NodeEntity memory node) private view returns (bool) 
    {
        return node.lastClaimTime + nodeTypes[node.nodeType].claimTime <= block.timestamp;
    }

    function _getRewardAmountOf(address account) external view override returns (uint256)
    {
        require(isNodeOwner(account));
        uint256 rewardCount = 0;

        NodeEntity[] storage nodes = _nodesOfUser[account];

        for (uint256 i = 0; i < nodes.length; i++) {
            rewardCount += nodes[i].rewardAvailable;
        }

        return rewardCount;
    }

    function _changeAutoDistri(bool newMode, uint256 newGasDistri) external override
    {
        require(msg.sender == token || msg.sender == gateKeeper);
        autoDistri = newMode;
        gasForDistribution = newGasDistri;
    }

    function _getDefaultMaxWalletPercentSell() external view override returns (uint256[2] memory) 
    {
        return [defaultMaxWalletPercentSellNum, defaultMaxWalletPercentSellDen];
    }

    function _changeDefaultMaxWalletPercentSell(uint256 newDefaultMaxWalletPercentSellNum, uint256 newDefaultMaxWalletPercentSellDen) external override
    {
        require(msg.sender == token || msg.sender == gateKeeper);
        defaultMaxWalletPercentSellNum = newDefaultMaxWalletPercentSellNum;
        defaultMaxWalletPercentSellDen = newDefaultMaxWalletPercentSellDen;
    }

    function _getNodeTypeNumberOf(address account, uint8 nodeType) external view override returns (uint256) 
    {
        return nodeCounts[account][nodeType];
    }

    function _getNodeNumberOf(address account) external view override returns (uint256) 
    {
        return nodeOwners.get(account);
    }

    function isNodeOwner(address account) private view returns (bool) 
    {
        return nodeOwners.get(account) > 0;
    }

    function _isNodeOwner(address account) external view override returns (bool) 
    {
        return isNodeOwner(account);
    }

    function _distributeRewards() external override returns ( uint256, uint256, uint256)
    {
        require(msg.sender == token || msg.sender == gateKeeper);
        return distributeRewards(gasForDistribution);
    }
}