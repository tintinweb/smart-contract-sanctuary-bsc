//SPDX-License-Identifier: UNLICENSED
// File: contracts/token/BEP20/HelloBEP20.sol
/**
 * @title HelloBEP20
 * @author SmartContracts Tools (https://www.smartcontracts.tools)
 * @dev Implementation of the HelloBEP20
 */
import "./BEP20.sol";
pragma solidity ^0.8.0;

contract HelloBEP20 is BEP20 {
    constructor(
        string memory name_,
        string memory symbol_
    ) payable ERC20(name_, symbol_)  {
        _mint(_msgSender(), 10000e18);
    }
}