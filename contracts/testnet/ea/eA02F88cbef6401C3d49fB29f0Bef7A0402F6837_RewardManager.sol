/**
 *Submitted for verification at BscScan.com on 2022-02-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract RewardManager {

    struct NodeEntity {
        string name;                    // node name
        uint256 nodeType;
        uint256 creationTime;           // creation time of node
        uint256 lastClaimTime;          // last claim time of rewards
    } // Node information

    struct NodeType {
        uint256 nodePrice;           // price of node
        uint256 rewardPerDay;       // reward per node
        uint256 totalRewardReleased;
    }

    mapping(address => NodeEntity[]) private _nodesOfUser; // address -> Nodes which user have
    mapping(uint256 => NodeType) public nodeTypes;
    
    uint256 public claimTime;           // user can claim only if lastClaimTime + claimTime < now

    address public gateKeeper;          // creator of this reward manager
    address public token;               // this will be Marvel token address

    uint256 public totalNodesCreated = 0;       // total nodes number
    uint256[] public types;

    constructor(
        uint256 _claimTime
    ) {
        claimTime = _claimTime;
        gateKeeper = msg.sender;
    }

    modifier onlySentry() {
        require(msg.sender == token || msg.sender == gateKeeper, "Fuck off");
        _;
    }

    function setToken(address token_) external onlySentry {
        token = token_;
    }

    function addNewNodeType(uint256 typeNum, uint256 nodePrice, uint256 rewardPerDay) public onlySentry {
        require(nodeTypes[typeNum].nodePrice == 0, "Type name is already used");
        require(nodePrice != 0, "Node price should be above zero");
        require(rewardPerDay != 0, "Reward should be above zero");
        nodeTypes[typeNum] = NodeType({
                                        nodePrice: nodePrice,
                                        rewardPerDay: rewardPerDay,
                                        totalRewardReleased: 0
                                    });
    }

    function removeNodeType(uint256 typeNum) public onlySentry {
        require(nodeTypes[typeNum].nodePrice > 0, "Type name is not existing");
        delete nodeTypes[typeNum];
    }

    function changeNodeType(uint256 typeNum, uint256 nodePrice, uint256 rewardPerDay) public onlySentry {
        require(nodeTypes[typeNum].nodePrice != 0, "Type name is not existing.");
        require(nodePrice != 0, "Node price should be above zero");
        require(rewardPerDay != 0, "Reward should be above zero");
        require(nodeTypes[typeNum].nodePrice != nodePrice || nodeTypes[typeNum].rewardPerDay != rewardPerDay, "No change");

        NodeType storage _nodeType = nodeTypes[typeNum];
        _nodeType.nodePrice = nodePrice;
        _nodeType.rewardPerDay = rewardPerDay;
    }

    function changeNodePrice(uint256 typeNum, uint256 nodePrice) public onlySentry {
        require(nodeTypes[typeNum].nodePrice != 0, "Type name is not existing.");
        require(nodePrice != 0, "Node price should be above zero");
        require(nodeTypes[typeNum].nodePrice != nodePrice, "New price is same as old name");

        NodeType storage _nodeType = nodeTypes[typeNum];
        _nodeType.nodePrice = nodePrice;
    }

    function changeNodeReward(uint256 typeNum, uint256 rewardPerDay) public onlySentry {
        require(nodeTypes[typeNum].nodePrice != 0, "Type name is not existing.");
        require(rewardPerDay != 0, "Reward should be above zero");
        require(nodeTypes[typeNum].rewardPerDay != rewardPerDay, "Reward value is same as old one");

        NodeType storage _nodeType = nodeTypes[typeNum];
        _nodeType.rewardPerDay = rewardPerDay;
    }

    function getNodeType(uint256 typeNum) public view returns(uint256 nodePrice, uint256 rewardPerDay, uint256 totalRewardReleased) {
        require(nodeTypes[typeNum].nodePrice != 0, "Type name is not existing.");
        return (nodeTypes[typeNum].nodePrice, nodeTypes[typeNum].rewardPerDay, nodeTypes[typeNum].totalRewardReleased);
    }

    // Create New Node
    function createNode(address account, uint256 nodeType, string memory nodeName)
        external
        onlySentry
    {
        require(
            isNameAvailable(account, nodeName),
            "CREATE NODE: Name not available"
        );
        _nodesOfUser[account].push(
            NodeEntity({
                name: nodeName,
                nodeType: nodeType,
                creationTime: block.timestamp,
                lastClaimTime: block.timestamp
            })
        );
        totalNodesCreated++;
    }

    // Node creator can't use already used name by him
    function isNameAvailable(address account, string memory nodeName)
        private
        view
        returns (bool)
    {
        NodeEntity[] memory nodes = _nodesOfUser[account];
        for (uint256 i = 0; i < nodes.length; i++) {
            if (keccak256(bytes(nodes[i].name)) == keccak256(bytes(nodeName))) {
                return false;
            }
        }
        return true;
    }

    // Search Node created at specific time
    function _getNodeWithCreatime(
        NodeEntity[] storage nodes,
        uint256 _creationTime
    ) private view returns (NodeEntity storage) {
        uint256 numberOfNodes = nodes.length; // 0,1,2,3 = length = 4
        require(
            numberOfNodes > 0,
            "CASHOUT ERROR: You don't have nodes to cash-out"
        );
        bool found = false;
        int256 index = binary_search(nodes, 0, numberOfNodes, _creationTime);
        uint256 validIndex;
        if (index >= 0) {
            found = true;
            validIndex = uint256(index);
        }
        require(found, "NODE SEARCH: No NODE Found with this blocktime");
        return nodes[validIndex];
    }

    function binary_search(
        NodeEntity[] memory arr,
        uint256 low,
        uint256 high,
        uint256 x
    ) private view returns (int256) {
        if (high >= low) {
            uint256 mid = (high + low)  / 2;
            if (arr[mid].creationTime == x) {
                return int256(mid);
            } else if (arr[mid].creationTime > x) {
                return binary_search(arr, low, mid - 1, x);
            } else {
                return binary_search(arr, mid + 1, high, x);
            }
        } else {
            return -1;
        }
    }

    // Get amount of rewards of node
    function _cashoutNodeReward(address account, uint256 _creationTime)
        external
        onlySentry
        returns (uint256)
    {
        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 numberOfNodes = nodes.length;
        require(
            numberOfNodes > 0,
            "CASHOUT ERROR: You don't have nodes to cash-out"
        );
        NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
        (, uint256 rewardPerDay,) = getNodeType(node.nodeType);
        uint256 rewardNode = (block.timestamp - node.lastClaimTime) * (rewardPerDay / 86400);
        node.lastClaimTime = block.timestamp;
        NodeType storage _nodeType = nodeTypes[node.nodeType];
        _nodeType.totalRewardReleased += rewardNode;
        return rewardNode;
    }

    // Get sum of all nodes' rewards 
    function _cashoutAllNodesReward(address account)
        external
        onlySentry
        returns (uint256)
    {
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        require(nodesCount > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity storage _node;
        NodeType storage _nodeType;
        uint256 rewardsTotal = 0;
        for (uint256 i = 0; i < nodesCount; i++) {
            _node = nodes[i];
            _nodeType = nodeTypes[_node.nodeType];
            (, uint256 rewardPerDay,) = getNodeType(nodes[i].nodeType);
            _nodeType.totalRewardReleased += (block.timestamp - _node.lastClaimTime) * (rewardPerDay / 86400);
            _node.lastClaimTime = block.timestamp;
            rewardsTotal += (block.timestamp - _node.lastClaimTime) * (rewardPerDay / 86400);
        }
        return rewardsTotal;
    }

    function _cashoutNodeTypeReward(address account, uint256 typeNum)
        external
        onlySentry
        returns (uint256)
    {
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        require(nodesCount > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity storage _node;
        NodeType storage _nodeType;
        uint256 rewardsTotal = 0;
        for (uint256 i = 0; i < nodesCount; i++) {
            if (nodes[i].nodeType == typeNum) {
                _node = nodes[i];
                _nodeType = nodeTypes[_node.nodeType];
                (, uint256 rewardPerDay,) = getNodeType(nodes[i].nodeType);
                _nodeType.totalRewardReleased += (block.timestamp - _node.lastClaimTime) * (rewardPerDay / 86400);
                _node.lastClaimTime = block.timestamp;
                rewardsTotal += (block.timestamp - _node.lastClaimTime) * (rewardPerDay / 86400);
            }
        }
        return rewardsTotal;
    }

    // Check claim time is passed after lastClaimTime. In other words, Can claim claimTime after lastClaimTime
    function claimable(NodeEntity memory node) private view returns (bool) {
        return node.lastClaimTime + claimTime <= block.timestamp;
    }

    // Get sum of all nodes' rewards owned by account
    function _getRewardAmountOf(address account)
        external
        view
        returns (uint256)
    {
        require(isNodeOwner(account), "GET REWARD OF: NO NODE OWNER");
        uint256 nodesCount;
        uint256 rewardCount = 0;

        NodeEntity[] storage nodes = _nodesOfUser[account];
        nodesCount = nodes.length;

        for (uint256 i = 0; i < nodesCount; i++) {
            (, uint256 rewardPerDay,) = getNodeType(nodes[i].nodeType);
            rewardCount += (block.timestamp - nodes[i].lastClaimTime) * (rewardPerDay / 86400);
        }
        return rewardCount;
    }

    // Get Reward amount of Node
    function _getRewardAmountOf(address account, uint256 _creationTime)
        external
        view
        returns (uint256)
    {
        require(isNodeOwner(account), "GET REWARD OF: NO NODE OWNER");

        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 numberOfNodes = nodes.length;
        require(
            numberOfNodes > 0,
            "CASHOUT ERROR: You don't have nodes to cash-out"
        );
        NodeEntity memory node = _getNodeWithCreatime(nodes, _creationTime);
        (, uint256 rewardPerDay,) = getNodeType(node.nodeType);
        uint256 rewardNode = (block.timestamp - node.lastClaimTime) * (rewardPerDay / 86400);
        return rewardNode;
    }

    // Get node names of account
    function _getNodesInfo(address account)
        external
        view
        returns (string memory)
    {
        require(isNodeOwner(account), "GET NAMES: NO NODE OWNER");
        NodeEntity[] memory nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        NodeEntity memory _node;
        string memory info = "";
        string memory separator = "#";
        for (uint256 i = 0; i < nodesCount; i++) {
            _node = nodes[i];
            info = string(abi.encodePacked(info, separator, 
            _node.name, separator, 
            uint2str(_node.nodeType), separator, 
            uint2str(_node.creationTime), separator, 
            uint2str(_node.lastClaimTime)));
        }
        return info;
    }

    // // Get times of all nodes created by account
    function _getNodesCreationTime(address account)
        external
        view
        returns (string memory)
    {
        require(isNodeOwner(account), "GET CREATIME: NO NODE OWNER");
        NodeEntity[] memory nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        NodeEntity memory _node;
        string memory _creationTimes = uint2str(nodes[0].creationTime);
        string memory separator = "#";

        for (uint256 i = 1; i < nodesCount; i++) {
            _node = nodes[i];

            _creationTimes = string(
                abi.encodePacked(
                    _creationTimes,
                    separator,
                    uint2str(_node.creationTime)
                )
            );
        }
        return _creationTimes;
    }


    // Get last claim times of all nodes created by account
    function _getNodesLastClaimTime(address account)
        external
        view
        returns (string memory)
    {
        require(isNodeOwner(account), "LAST CLAIME TIME: NO NODE OWNER");
        NodeEntity[] memory nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        NodeEntity memory _node;
        string memory _lastClaimTimes = uint2str(nodes[0].lastClaimTime);
        string memory separator = "#";

        for (uint256 i = 1; i < nodesCount; i++) {
            _node = nodes[i];

            _lastClaimTimes = string(
                abi.encodePacked(
                    _lastClaimTimes,
                    separator,
                    uint2str(_node.lastClaimTime)
                )
            );
        }
        return _lastClaimTimes;
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }


    function _changeClaimTime(uint256 newTime) external onlySentry {
        claimTime = newTime;
    }

    // Get number of nodes created by account
    function _getNodeNumberOf(address account) public view returns (uint256) {
        return _nodesOfUser[account].length;
    }

    // Check if account has node or not
    function isNodeOwner(address account) private view returns (bool) {
        return _nodesOfUser[account].length > 0;
    }

    function _isNodeOwner(address account) external view returns (bool) {
        return isNodeOwner(account);
    }

}