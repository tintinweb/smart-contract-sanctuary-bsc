// contracts/SmartNode.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartNode {
    mapping (address => address) private nodes;
    mapping (uint256 => address) private nodeIds;
    uint256 private currentId = 0;

    event SmartNodeActivated(address user, address referer, uint256 id);

    function join(address referer) public {
        require(nodes[msg.sender] == address(0), "Already joined!");
        currentId++;
        nodes[msg.sender] = referer;
        nodeIds[currentId] = msg.sender;
        emit SmartNodeActivated(msg.sender, referer, currentId);
    }

    function nodeRefererOf(address _node) public view returns(address referer) {
        return nodes[_node];
    }

    function nodeUserOf(uint256 _id) public view returns(address node) {
        return nodeIds[_id];
    }

    function nodeUserReferrerOf(uint256 _id) public view returns(address node, address referer) {
        return (nodeIds[_id], nodes[nodeIds[_id]]);
    }

    function totalNodes() public view returns(uint256 nodeCount) {
        return currentId;
    }

    function isExistingId(uint256 _id) public view returns(bool status) {
        return nodeIds[_id] != address(0);
    }
}