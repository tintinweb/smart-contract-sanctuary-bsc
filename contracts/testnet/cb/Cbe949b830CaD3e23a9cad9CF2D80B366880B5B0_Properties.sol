//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Properties {
  address private owner;
  Property[] private properties;

  struct Property {
    string PropertyType;
    string PropertyGroup;
    string Name;
    int16 Price;
    int16 Build;
    int16 Level0;
    int16 Level1;
    int16 Level2;
    int16 Level3;
    int16 Level4;
    int16 Level5;
    int16 Level6;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  constructor() {
    owner = msg.sender;
  }

  function initializeProperty(Property memory property) public onlyOwner {
    properties.push(property);
  }

  function loadProperties() public view onlyOwner returns (Property[] memory) {
    return properties;
  }
}