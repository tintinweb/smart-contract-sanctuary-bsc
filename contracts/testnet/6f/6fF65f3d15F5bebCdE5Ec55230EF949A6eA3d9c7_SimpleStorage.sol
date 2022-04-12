//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract SimpleStorage {
  // mapping(address => Pass[]) passes;
  address private owner;
  Pass[] private passes;

  struct Pass {
    string first_name;
    string last_name;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  constructor() {
    owner = msg.sender;
  }

  function submitPass() public onlyOwner {
    // passes[msg.sender].push(Pass({first_name: 'Alain', last_name: 'Goldman'}));
    passes.push(Pass({first_name: 'Alain', last_name: 'Goldman'}));
  }

  function whatsInFirst() public view returns (Pass memory) {
    require(msg.sender == owner, 'This can only be called by the contract owner!');
    // return passes[msg.sender][1].first_name;
    return passes[0];
  }
}

// contract SimpleStorage {
//   // Initialising array numbers
//   int256[] public numbers;

//   // Function to insert values
//   // in the array numbers
//   function Numbers() public {
//     numbers.push(1);
//     numbers.push(2);

//     //Creating a new instance
//     int256[] storage myArray = numbers;

//     // Adding value to the
//     // first index of the new Instance
//     myArray[0] = 0;
//   }
// }