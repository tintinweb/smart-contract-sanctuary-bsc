// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

contract KVStore {
    uint private constant MAX_STRING_LENGTH = 1000;
    mapping(address => mapping(string => string)) private store;

    event DataSaved(address indexed sender, string key, string value);

    function get(
        address _account,
        string memory _key
    ) public view returns (string memory) {
        return store[_account][_key];
    }

    function set(string memory _key, string memory _value) public {
        require(
            bytes(_key).length <= MAX_STRING_LENGTH &&
                bytes(_value).length <= MAX_STRING_LENGTH,
            'Maximum string length'
        );
        store[msg.sender][_key] = _value;
        emit DataSaved(msg.sender, _key, _value);
    }
}