/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7 <0.9.0;

contract BlockTalk {
    event Comment(uint256 indexed topicid, address indexed sender, string content);
    struct Topic {
        address owner;
        string uri;
    }
    uint256 public maxTopicId;
    mapping (uint256 => Topic) public topics;
    
    function comment(uint256 topicid, string memory content) public{
        require(topics[topicid].owner != address(0), "Topic is not existed");
        emit Comment(topicid, msg.sender, content);
    }

    function add(string memory uri) public returns (uint256) {
        maxTopicId = maxTopicId + 1;
        topics[maxTopicId] = Topic(msg.sender, uri);
        return maxTopicId;
    }

    function edit(uint256 topicid, string memory uri) public{
        require(topics[topicid].owner != address(0), "Topic is not existed");
        require(topics[topicid].owner == msg.sender, "You are not owner of this topic");
        topics[topicid].uri = uri;
    }
}