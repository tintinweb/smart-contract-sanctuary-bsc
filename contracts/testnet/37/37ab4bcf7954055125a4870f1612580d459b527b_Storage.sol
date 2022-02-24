// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract Storage {
    event Allowed(address operator, address remote, bool allowed);
    address owner;

    // contract interactor -->  permited
    mapping(address => bool) internal permited;

    function setPermited(address _remote, bool _enabled) external {
        require(owner == msg.sender, 'only owner can set permited');
        require(_remote.code.length > 0, 'remote has to be a contract');
        permited[_remote] = _enabled;
        emit Allowed(msg.sender, _remote, _enabled);
    }

    function isPermited(address remote) view external returns(bool) {
        return permited[remote];
    }

    modifier onlyPermited() {
        require(permited[msg.sender], 'only permited contracts can interact');
        _;
    }


    // ADDRESS

    // namespace -> key -> address
    mapping(bytes32 => mapping(bytes32 => address)) private addressMap;

    function setAddress(bytes32 _namespace, bytes32 _key, address _value) external onlyPermited() {
        addressMap[_namespace][_key] = _value;
    }

    function setBatchAddressWith(bytes32 _namespace, bytes32[] calldata _keys, address _value) external onlyPermited() {
        for(uint256 i = 0; i < _keys.length; i++) {
            addressMap[_namespace][_keys[i]] = _value;
        }
    }

    function getAddress(bytes32 _namespace, bytes32 _key) view external onlyPermited() returns(address) {
        return addressMap[_namespace][_key];
    }


    // uint

    // namespace -> key -> uint
    mapping(bytes32 => mapping(bytes32 => uint)) private uintMap;

    function setUint(bytes32 _namespace, bytes32 _key, uint _value) external onlyPermited() {
        uintMap[_namespace][_key] = _value;
    }

    function setBatchUint(bytes32 _namespace, bytes32[] calldata _keys, uint[] calldata _values) external onlyPermited() {
        for(uint256 i = 0; i < _keys.length; i++) {
            uintMap[_namespace][_keys[i]] = _values[i];
        }
    }

    function setBatchUintWith(bytes32 _namespace, bytes32[] calldata _keys, uint _value) external onlyPermited() {
        for(uint256 i = 0; i < _keys.length; i++) {
            uintMap[_namespace][_keys[i]] = _value;
        }
    }

    function incUint(bytes32 _namespace, bytes32 _key, uint _value) external onlyPermited() returns(uint256) {
        uintMap[_namespace][_key] += _value;
        return uintMap[_namespace][_key];
    }

    function decUint(bytes32 _namespace, bytes32 _key, uint _value) external onlyPermited() returns(uint256) {
        uintMap[_namespace][_key] -= _value;
        return uintMap[_namespace][_key];
    }

    function movUint(bytes32 _namespace, bytes32 _from, bytes32 _to, uint _value) external onlyPermited() {
        uintMap[_namespace][_from] -= _value;
        uintMap[_namespace][_to] += _value;
    }

    function getUint(bytes32 _namespace, bytes32 _key) view external onlyPermited() returns(uint) {
        return uintMap[_namespace][_key];
    }

    // uint array

    // namespace -> key -> uint[]
    mapping(bytes32 => mapping(bytes32 => uint[])) private uintArrayMap;

    function pushToUintArray(bytes32 _namespace, bytes32 _key, uint _value) external onlyPermited() {
        uintArrayMap[_namespace][_key].push(_value);
    }

    function getUintArray(bytes32 _namespace, bytes32 _key) view external onlyPermited() returns(uint[] memory) {
        return uintArrayMap[_namespace][_key];
    }

    // BYTES

    // namespace -> key -> bytes
    mapping(bytes32 => mapping(bytes32 => bytes)) private bytesMap;

    function setBytes(bytes32 _namespace, bytes32 _key, bytes calldata _value) external onlyPermited() {
        bytesMap[_namespace][_key] = _value;
    }

    function setBatchBytes(bytes32 _namespace, bytes32[] calldata _keys, bytes[] calldata _values) external onlyPermited() {
        for(uint256 i = 0; i < _keys.length; i++) {
            bytesMap[_namespace][_keys[i]] = _values[i];
        }
    }

    function getBytes(bytes32 _namespace, bytes32 _key) view external onlyPermited() returns(bytes memory) {
        return bytesMap[_namespace][_key];
    }


    constructor() {
        owner = msg.sender;
    }
}