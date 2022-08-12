// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

contract Manija {
    
    string private message = 'Manija team not dead';
    
    function reveal() public view returns (string memory) {
        return message;
    }
}