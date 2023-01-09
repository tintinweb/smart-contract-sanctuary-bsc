//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20Burnable.sol";

contract JustClickMeToken is ERC20Burnable {

    constructor(uint256 _initialSupply) ERC20('Just Click Me', 'JCM', 3){
        _mint(msg.sender, _initialSupply);
    }
}