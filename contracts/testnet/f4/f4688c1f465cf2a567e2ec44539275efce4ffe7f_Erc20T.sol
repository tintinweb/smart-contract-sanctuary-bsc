// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./ERC20.sol";

contract Erc20T is ERC20{


    constructor(uint _totalSuperNum) ERC20("tq","Tq1") {
        _mint(msg.sender,_totalSuperNum);
    }

}