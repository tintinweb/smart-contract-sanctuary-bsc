/**
 * @title STABLE
 * @dev STABLE contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: GNU GPLv2
 *
 **/

pragma solidity 0.6.12;

import "./ERC20.sol";

contract STABLE is ERC20 {
    constructor() public ERC20("Torsten", "Torsten") {}
}