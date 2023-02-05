/**
 * @title receipt STABLE
 * @dev receiptSTABLE contract
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: GNU GPLv2
 *
 **/

pragma solidity 0.6.12;

import "./ERC20.sol";

contract receiptSTABLE is ERC20 {
    constructor() public ERC20("receiptSTABLE", "reSTABLE") {}
}