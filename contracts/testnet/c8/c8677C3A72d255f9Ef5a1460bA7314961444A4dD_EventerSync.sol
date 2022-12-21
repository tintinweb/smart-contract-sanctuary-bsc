// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract EventerSync {
    event D(uint256 tokenId, string ipfsHash);
    event T(uint256 tokenId, string ipfsHash);
    event J(address sender, uint256 tokenId, string ipfsHash);

    function eventerLog() public {
        emit D(1, "a");
        emit T(2, "b");
        emit J(msg.sender, 3, "c");
        emit J(msg.sender, 4, "D");
        emit J(msg.sender, 5, "E");
        emit J(msg.sender, 6, "F");
        emit J(msg.sender, 7, "G");
        emit J(msg.sender, 8, "r");
        emit J(msg.sender, 9, "H");
        emit J(msg.sender, 10, "N");
    }
}