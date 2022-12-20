// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Eventer {
    event A(uint256 tokenId, string ipfsHash);
    event B(uint256 tokenId, string ipfsHash);
    event C(address sender, uint256 tokenId, string ipfsHash);

    function eventerLog() public {
        emit A(1, "a");
        emit B(2, "b");
        emit C(msg.sender, 3, "c");
        emit C(msg.sender, 4, "D");
        emit C(msg.sender, 5, "E");
        emit C(msg.sender, 6, "F");
        emit C(msg.sender, 7, "G");
        emit C(msg.sender, 8, "r");
        emit C(msg.sender, 9, "H");
        emit C(msg.sender, 10, "N");
    }
}