// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

contract LaBanda {
    
    string private message = 'Salud Banda! Are Lider!';
    
    function click() public view returns (string memory) {
        return message;
    }
}