// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract GLDToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("XIAOCAI", "xc") {
        _mint(msg.sender, initialSupply);
    }

    uint a =10;

}