// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0; 

import "./ERC721Full.sol";

contract Token is ERC721Full{

  string[] public tokens;
  mapping(string => bool) _tokenExists;

  constructor() ERC721Full("GoldenX", "GOLDEN") public {
  }

  // E.G. Token = "Your Full Name"
  function mint(string memory _token) public {
    
    require(!_tokenExists[_token]);

    tokens.push(_token);
    uint _id = tokens.length - 1;

    _mint(msg.sender, _id);
    _tokenExists[_token] = true;
  }

}