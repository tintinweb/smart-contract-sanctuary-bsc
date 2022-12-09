// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library IterableArbiters {

    struct UserVote {
        address voter;
        bool agree;
        bool voted;
    }

    struct Map {
        address[] keys;
        mapping(address => UserVote) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    /// @notice Check if `key` is in `map`
    /// @param map The storage map
    /// @param key The key to check if it is in `map`
    /// @return if `key` is in `map`
    function contains(Map storage map, address key) public view returns (bool) {
        return map.inserted[key];
    }

    /// @notice Get the `UserVote` object of `key` in `map`
    /// @param map The storage map
    /// @param key The key to fetch the `UserVote` object of
    /// @return `UserVote` of `key`
    function get(Map storage map, address key) public view returns (UserVote memory) {
        return map.values[key];
    }

    /// @notice Get the Index of `key`
    /// @param map The storage map
    /// @param key The key to fetch index of
    /// @return index of `key`
    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        require(map.indexOf[key] < 2**255, "index too large");
        return int(map.indexOf[key]);
    }

    /// @notice Get the `key` at `index`
    /// @param map The storage map
    /// @param index The index of key to fetch
    /// @return `key` at `index`
    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    /// @notice Get total keys in the `map`
    /// @param map The storage map
    /// @return the length of `keys`
    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    /// @notice Sets `key` to `val` and update other fields
    /// @dev This function is used to update the `UserVote` object of `key` in `map`
    /// @param map The storage map
    /// @param key Key to update
    /// @param val Value to set `key` to
    function set(Map storage map, address key, UserVote memory val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    /// @notice Removes `key` from `map`
    /// @dev Resets all `key` fields to default values
    /// @param map The storage map
    /// @param key Key to remove
    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();

    }

    /// @notice Returns all `UserVote` as an array
    /// @dev Used by the consumer to get just the `UserVote` objects of all `keys` in `map`
    /// @param map The storage map
    /// @return array of `UserVote` objects
    function asArray(Map storage map) public view returns (UserVote[] memory) {
        UserVote[] memory result = new UserVote[](map.keys.length);

        for (uint256 index = 0; index < map.keys.length; index++) {
            result[index] = map.values[map.keys[index]];
        }
        return result;
    }

    /// @notice Returns all `keys`
    /// @dev Used by the consumer to get just the `users`  in `map`
    /// @param map The storage map
    /// @return array of `address` objects
    function keysAsArray(Map storage map) public view returns (address[] memory) {
        return map.keys;
    }
}