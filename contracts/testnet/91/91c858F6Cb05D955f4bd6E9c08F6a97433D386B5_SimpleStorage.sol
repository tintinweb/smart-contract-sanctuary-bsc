//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract SimpleStorage {
  // mapping(address => Pass[]) passes;
  Pass[] private passes;

  struct Pass {
    string first_name;
    string last_name;
  }

  function submitPass() public {
    // passes[msg.sender].push(Pass({first_name: 'Alain', last_name: 'Goldman'}));
    passes.push(Pass({first_name: 'Alain', last_name: 'Goldman'}));
  }

  function whatsInFirst() public view returns (string memory) {
    // return passes[msg.sender][1].first_name;
    return passes[1].first_name;
  }
}