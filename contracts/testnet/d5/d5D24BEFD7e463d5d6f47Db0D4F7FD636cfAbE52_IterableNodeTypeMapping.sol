// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

library IterableNodeTypeMapping {
    //# types of node tiers
    //# each node type's properties are different
    struct NodeType {
        string nodeTypeName;
        uint256 nodePrice;          //# cost to buy a node
        uint256 claimTime;          //# length of an epoch
        uint256 rewardAmount;       //# reward per an epoch
        uint256 claimTaxBeforeTime; //# claim tax before claimTime is passed
		uint256 count; // created Node Count
		uint256 max; // max nodes
		uint256 earlyClaimTax; // before roi tax
		uint256 maxLevelUpGlobal; // max remaining levelup to get this node for everyone
		uint256 maxLevelUpUser; // max authorized levelUp per user for this node
		uint256 maxCreationPendingGlobal; // max remaining creation with pending for everyone
		uint256 maxCreationPendingUser; // max authorized creation with pending for a user
    }

    // Iterable mapping from string to NodeType;
    struct Map {
        string[] keys;
        mapping(string => NodeType) values;
        mapping(string => uint256) indexOf;
        mapping(string => bool) inserted;
    }

    function get(Map storage map, string memory key) public view returns (NodeType storage) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, string memory key)
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
    returns (string memory)
    {
        return map.keys[index];
    }

    function getValueAtIndex(Map storage map, uint256 index)
    public
    view
    returns (NodeType memory)
    {
        return map.values[map.keys[index]];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        string memory key,
        NodeType memory value
    ) public {
        if (map.inserted[key]) {
            map.values[key] = value;
        } else {
            map.inserted[key] = true;
            map.values[key] = value;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, string memory key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        string memory lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}