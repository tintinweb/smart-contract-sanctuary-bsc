// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Random {
     function rand() external returns (uint256);
}

contract Test {
    function random(address add) public returns(uint256) {
       return Random(add).rand();
    }
}