// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract SimpleContract  {
  uint256 private _value;
  // Emitted when the stored value changes
  event ValueChanged(uint256 value);


  // Stores a new value in the contract
  function store(uint256 value) public {
    //require(msg.sender == _petOwner, "UpgradeablePet: not owner");
    _value = value;
    emit ValueChanged(value);
  }

  // Reads the last stored value
  function retrieve() public view returns (uint256) {
    return _value;
  }
}