// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

library EternalStorage {
  struct Data {
    mapping(bytes32 => uint256) uintData;
    mapping(bytes32 => string) stringData;
    mapping(bytes32 => address) addressData;
    mapping(bytes32 => bytes) bytesData;
    mapping(bytes32 => bool) boolData;
    mapping(bytes32 => int256) intData;
  }

  function setUInt(
    Data storage data,
    bytes32 key,
    uint256 value
  ) internal {
    data.uintData[key] = value;
  }

  function getUInt(Data storage data, bytes32 key)
    internal
    view
    returns (uint256)
  {
    return data.uintData[key];
  }

  function setString(
    Data storage data,
    bytes32 key,
    string memory value
  ) internal {
    data.stringData[key] = value;
  }

  function getString(Data storage data, bytes32 key)
    internal
    view
    returns (string memory)
  {
    return data.stringData[key];
  }

  function setAddress(
    Data storage data,
    bytes32 key,
    address value
  ) internal {
    data.addressData[key] = value;
  }

  function getAddress(Data storage data, bytes32 key)
    internal
    view
    returns (address)
  {
    return data.addressData[key];
  }

  function setBytes(
    Data storage data,
    bytes32 key,
    bytes memory value
  ) internal {
    data.bytesData[key] = value;
  }

  function getBytes(Data storage data, bytes32 key)
    internal
    view
    returns (bytes memory)
  {
    return data.bytesData[key];
  }

  function setBool(
    Data storage data,
    bytes32 key,
    bool value
  ) internal {
    data.boolData[key] = value;
  }

  function getBool(Data storage data, bytes32 key)
    internal
    view
    returns (bool)
  {
    return data.boolData[key];
  }

  function setInt(
    Data storage data,
    bytes32 key,
    int256 value
  ) internal {
    data.intData[key] = value;
  }

  function getInt(Data storage data, bytes32 key)
    internal
    view
    returns (int256)
  {
    return data.intData[key];
  }

  function setRole(
    Data storage data,
    bytes32 key,
    bytes32 value
  ) internal {
    setBytes(data, key, abi.encodePacked(value));
  }

  function getRole(Data storage data, bytes32 key)
    internal
    view
    returns (bytes32)
  {
    return bytes32(getBytes(data, key));
  }
}