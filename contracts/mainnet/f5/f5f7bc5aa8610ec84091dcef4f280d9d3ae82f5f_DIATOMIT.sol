/**
 * @title DIATOMIT
 * @dev DIATOMIT contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: GNU GPLv2
 *
 **/

pragma solidity 0.6.12;

import "./ERC20.sol";

contract DIATOMIT is ERC20 {
    constructor() public ERC20("DIATOMIT", "DIA") {}
}