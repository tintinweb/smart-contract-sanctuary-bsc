// contracts/BoxV2.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './Box.sol';

contract BoxV2 is Box {
  // Increasements stored value 1
  function increment() public {
    store(retrieve() + 1);
  }
}

// contracts/Box.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Box {
  uint256 private value;

  // Emit when sorted value changes
  event ValueChanged(uint256 newValue);

  //Stores a new value in contract
  function store(uint256 newValue) public {
    value = newValue;
    emit ValueChanged(newValue);
  }

  //Read last store value
  function retrieve() public view returns (uint256) {
    return value;
  }
}