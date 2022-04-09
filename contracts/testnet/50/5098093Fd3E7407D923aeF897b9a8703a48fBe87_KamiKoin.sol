// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;


import "./ERC1155.sol";

contract KamiKoin is ERC1155 {
    uint256 public constant FUNGIBLE = 99999999999999999;
    uint256 public constant NON_FUNGIBLE = 1;

    constructor() ERC1155("JSON_URI") {
        _mint(msg.sender, FUNGIBLE, 999999999999999999, "Kami");
        _mint(msg.sender, NON_FUNGIBLE, 1, "");
    }
}