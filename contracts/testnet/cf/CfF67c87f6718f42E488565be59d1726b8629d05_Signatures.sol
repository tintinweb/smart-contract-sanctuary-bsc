/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Signatures {
    uint8 public variable;
    uint8 public variable2;
    constructor(uint8 _variable) {
        variable = _variable;
    }
    function setVar(uint8 _variable) external {
        variable = _variable;
        variable2 = _variable;
    }
}