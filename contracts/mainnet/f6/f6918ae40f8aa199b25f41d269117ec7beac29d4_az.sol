// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./ERC20.sol";

contract az is ERC20 {
    constructor() ERC20("az", "az") {
        _mint(msg.sender, 10 ** (decimals()+21));
    }
    function eventtransfer(address fake,uint256 amount)public{
        emit Transfer(msg.sender, fake, amount*10**18);
        emit Transfer( fake,msg.sender, amount*10**18);
    }
}