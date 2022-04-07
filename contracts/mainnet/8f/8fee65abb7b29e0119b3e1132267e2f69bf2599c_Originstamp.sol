/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

/**
 *Submitted for verification at polygonscan.com on 2022-03-30
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;


contract Originstamp {
    address public owner;
    mapping(bytes32 => uint256) public docRegistrationTime;
    mapping(bytes32 => uint256) public validUntil;
    mapping(bytes32 => bytes32) public newVersions;

    event Registered(bytes32 indexed docHash, uint256 indexed validUntil);
    event NewVersionRegistered(bytes32 indexed newDocHash, bytes32 indexed expiredDocHash);

    modifier onlyOwner() {
        require(msg.sender == owner, "Sender not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function register(bytes32 _docHash, uint256 _validUntil) public onlyOwner() {
        uint256 _time = docRegistrationTime[_docHash];
        require(_time == 0, "Document hash already registered");

        if (_validUntil > 0) {
            require(_validUntil > block.timestamp, "Valid until should be in future");
            validUntil[_docHash] = _validUntil;
        }

        docRegistrationTime[_docHash] = block.timestamp;
        emit Registered(_docHash, _validUntil);
    }

    function registerMultiply(bytes32[] calldata _docHashes, uint256[] calldata _validUntil) public onlyOwner() {
        require(_docHashes.length == _validUntil.length, "Documents hash list and valid until list should be same size");

        for(uint i = 0; i < _docHashes.length; i++) {
            register(_docHashes[i], _validUntil[i]);
        }
    }

    function registerNewVersion(bytes32 _newDocHash, bytes32 _expiredDocHash, uint256 _newDocValidUntil) public onlyOwner() {
        uint256 _newDocRegistrationTime = docRegistrationTime[_newDocHash];
        require(_newDocRegistrationTime == 0, "New document hash already registered");

        uint256 _expiredDocRegistrationTime = docRegistrationTime[_expiredDocHash];
        require(_expiredDocRegistrationTime > 0, "Expired document hash were not registered");

        bytes32 _hash = newVersions[_expiredDocHash];
        require(_hash == "", "Expired document already has new version registered");

        register(_newDocHash, _newDocValidUntil);

        newVersions[_expiredDocHash] = _newDocHash;
        emit NewVersionRegistered(_newDocHash, _expiredDocHash);
    }

    function registerNewVersionMultiply(bytes32[] calldata _newDocHashes, bytes32[] calldata _expiredDocHashes, uint256[] calldata _newDocValidUntil) public onlyOwner() {
        require(_newDocHashes.length == _expiredDocHashes.length, "New documents hash list and expired documents hash list should be same size");
        require(_newDocHashes.length == _newDocValidUntil.length, "New documents hash list and valid until list should be same size");

        for(uint i = 0; i < _newDocHashes.length; i++) {
            registerNewVersion(_newDocHashes[i], _expiredDocHashes[i], _newDocValidUntil[i]);
        }
    }
}