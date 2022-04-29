// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Random {
     function rand() external returns (uint256);
}

contract Test {
    uint256 public output;
    function random(address add) public returns(uint256) {
       output = Random(add).rand();
       return output;
    }
}