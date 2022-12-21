// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

library IterableUintArrayWithoutDuplicateKeys {
    struct Map {
        uint256[] keys;
        mapping(uint256 => uint256) indexOf;
        mapping(uint256 => bool) inserted;
    }

    function getIndexOfKey(Map storage map, uint256 key)
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
        returns (uint256)
    {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function add(Map storage map, uint256 key) public {
        if (map.inserted[key]) {
            return;
        }
        map.inserted[key] = true;
        map.indexOf[key] = map.keys.length;
        map.keys.push(key);
    }

    function remove(Map storage map, uint256 key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        uint256 lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}